//
//  PackageManagerInstallOperation.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/8/25.
//

import Foundation
import Combine
import CodeEditCore

/// An executable install operation for installing a ``RegistryItem``.
///
/// Has a single entry point, ``run()``, which kicks off the operation. UI can observe properties like the ``error``,
/// ``runningState-swift.property``, or ``currentStep`` to monitor progress.
///
/// If a step requires confirmation, the ``waitingForConfirmation`` value will be filled.
@MainActor
public final class PackageManagerInstallOperation: ObservableObject, Identifiable {
    public enum RunningState {
        case none
        case running
        case complete
    }

    public struct OutputItem: Identifiable, Equatable {
        public let id: UUID = UUID()
        public let isStepDivider: Bool
        public let outputIdx: Int?
        public let contents: String

        public init(outputIdx: Int? = nil, isStepDivider: Bool = false, contents: String) {
            self.isStepDivider = isStepDivider
            self.outputIdx = outputIdx
            self.contents = contents
        }
    }

    nonisolated public var id: String { package.name }

    public let package: RegistryItem
    public let steps: [PackageManagerInstallStep]

    /// The step the operation is currently executing or stopped at.
    public var currentStep: PackageManagerInstallStep? {
        steps[safe: currentStepIdx]
    }

    /// The current state of the operation.
    public var runningState: RunningState {
        if operationTask != nil {
            return .running
        } else if error != nil || currentStepIdx == steps.count {
            return .complete
        } else {
            return .none
        }
    }

    @Published public var accumulatedOutput: [OutputItem] = []
    @Published public var currentStepIdx: Int = 0
    @Published public var error: Error?
    @Published public var progress: Progress

    /// If non-nil, indicates that this operation has halted and requires confirmation.
    @Published public private(set) var waitingForConfirmation: String?

    private let shellClient: ShellClientProtocol
    private var operationTask: Task<Void, Error>?
    private var confirmationContinuation: CheckedContinuation<Void, Never>?
    private var outputIdx = 0

    /// Create a new operation using a list of steps and a package description.
    /// See ``PackageManagerProtocol`` for 
    /// - Parameters:
    ///   - package: The package to install.
    ///   - steps: The steps that make up the operation.
    public init(package: RegistryItem, steps: [PackageManagerInstallStep], shellClient: ShellClientProtocol) {
        self.shellClient = shellClient
        self.package = package
        self.steps = steps
        self.progress = Progress(totalUnitCount: Int64(steps.count))
    }

    public func run() async throws {
        guard operationTask == nil else { return }
        operationTask = Task {
            defer { operationTask = nil }
            try await runNext()
        }
        try await operationTask?.value
    }

    public func cancel() {
        operationTask?.cancel()
        operationTask = nil
    }

    /// Called by UI to confirm continuing to the next step
    public func confirmCurrentStep() {
        waitingForConfirmation = nil
        confirmationContinuation?.resume()
        confirmationContinuation = nil
    }

    private func waitForConfirmation(message: String) async {
        waitingForConfirmation = message
        await withCheckedContinuation { [weak self] (continuation: CheckedContinuation<Void, Never>) in
            self?.confirmationContinuation = continuation
        }
    }

    private func runNext() async throws {
        guard currentStepIdx < steps.count, error == nil else {
            return
        }

        let task = steps[currentStepIdx]

        switch task.confirmation {
        case .required(let message):
            await waitForConfirmation(message: message)
        case .none:
            break
        }

        let model = PackageManagerProgressModel(shellClient: shellClient)
        progress.addChild(model.progress, withPendingUnitCount: 1)

        try Task.checkCancellation()
        accumulatedOutput.append(OutputItem(isStepDivider: true, contents: "Step \(currentStepIdx + 1): \(task.name)"))

        // `Task {}` inherits this method's main-actor isolation, so the capture of `model`
        // and `self` stays in-region (a task group's `addTask` requires `sending` closures,
        // which the non-Sendable progress model can't satisfy).
        let outputForwarding = Task {
            for await outputItem in model.outputStream {
                switch outputItem {
                case .status(let string):
                    self.outputIdx += 1
                    self.accumulatedOutput.append(OutputItem(outputIdx: self.outputIdx, contents: string))
                case .output(let string):
                    self.accumulatedOutput.append(OutputItem(contents: string))
                }
            }
        }

        do {
            try await task.handler(model)
        } catch {
            self.error = error
        }
        model.finish()
        // Drain the stream so all output lands before the next step begins.
        await outputForwarding.value

        self.currentStepIdx += 1

        try Task.checkCancellation()
        if let error {
            progress.cancel()
            throw error
        }
        try await runNext()
    }
}
