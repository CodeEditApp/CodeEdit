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
    struct OutputItem: Identifiable {
        var id: UUID = UUID()
        var contents: String
    }

    nonisolated var id: String { package.name }

    let package: RegistryItem
    let steps: [PackageManagerInstallStep]

    @Published var accumulatedOutput: [OutputItem] = []
    @Published var currentStep: Int = 0
    @Published var error: Error?
    @Published var progress: Progress

    private let shellClient: ShellClient = .live()
    private var operationTask: Task<Void, Error>?

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
    }

    private func runNext() async throws {
        guard currentStep < steps.count, error == nil else {
            return
        }

        let task = steps[currentStep]
        let model = PackageManagerProgressModel(shellClient: shellClient)
        progress.addChild(model.progress, withPendingUnitCount: 1)

        try Task.checkCancellation()
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                for await line in model.outputStream {
                    await MainActor.run {
                        self.accumulatedOutput.append(OutputItem(contents: line))
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

        self.currentStep += 1

        try Task.checkCancellation()
        if let error {
            throw error
        }
        try await runNext()
    }
}
