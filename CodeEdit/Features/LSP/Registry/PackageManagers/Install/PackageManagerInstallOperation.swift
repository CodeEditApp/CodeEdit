//
//  PackageManagerInstallOperation.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/8/25.
//

import Foundation
import Combine

@MainActor
final class PackageManagerInstallOperation: ObservableObject, Identifiable {
    struct OutputItem: Identifiable, Equatable {
        let id: UUID = UUID()
        let isStepDivider: Bool
        let outputIdx: Int?
        let contents: String

        init(outputIdx: Int? = nil, isStepDivider: Bool = false, contents: String) {
            self.isStepDivider = isStepDivider
            self.outputIdx = outputIdx
            self.contents = contents
        }
    }

    nonisolated var id: String { package.name }

    let package: RegistryItem
    let steps: [PackageManagerInstallStep]

    var currentStep: PackageManagerInstallStep? {
        steps[safe: currentStepIdx]
    }

    @Published var accumulatedOutput: [OutputItem] = []
    @Published var currentStepIdx: Int = 0
    @Published var error: Error?
    @Published var progress: Progress

    /// If non-nil, indicates that this operation has halted and requires confirmation.
    @Published public private(set) var waitingForConfirmation: String?

    private let shellClient: ShellClient = .live()
    private var operationTask: Task<Void, Error>?
    private var confirmationContinuation: CheckedContinuation<Void, Never>?
    private var outputIdx = 0

    init(package: RegistryItem, steps: [PackageManagerInstallStep]) {
        self.package = package
        self.steps = steps
        self.progress = Progress(totalUnitCount: Int64(steps.count))
    }

    func run() async throws {
        guard operationTask == nil else { return }
        operationTask = Task {
            try await runNext()
        }
        try await operationTask?.value
    }

    func cancel() {
        operationTask?.cancel()
        operationTask = nil
    }

    /// Called by UI to confirm continuing to the next step
    func confirmCurrentStep() {
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

        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                for await outputItem in model.outputStream {
                    await MainActor.run {
                        switch outputItem {
                        case .status(let string):
                            self.outputIdx += 1
                            self.accumulatedOutput.append(OutputItem(outputIdx: self.outputIdx, contents: string))
                        case .output(let string):
                            self.accumulatedOutput.append(OutputItem(contents: string))
                        }
                    }
                }
            }
            group.addTask {
                do {
                    try await task.handler(model)
                } catch {
                    await MainActor.run {
                        self.error = error
                    }
                }
                await MainActor.run {
                    model.finish()
                }
            }
        }

        self.currentStepIdx += 1

        try Task.checkCancellation()
        if let error {
            progress.cancel()
            throw error
        }
        try await runNext()
    }
}
