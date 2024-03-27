//
//  FakeTask.swift
//  CodeEdit
//
//  Created by Axel Martinez on 8/2/24.
//

import Foundation

/// Fake task for testing
class TestTask: ObservableObject, CETask {
    @Published var name: String

    init(name: String) {
        self.name = name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    static func == (lhs: TestTask, rhs: TestTask) -> Bool {
        lhs.name == rhs.name
    }

    func execute(_ taskRun: CETaskRun) async throws {
        let seconds = 4.0

        await taskRun.updateProgress("Executing task 1 of 2", progress: 0.33)

        try await Task.sleep(nanoseconds: UInt64(seconds * Double(NSEC_PER_SEC)))

        await taskRun.updateProgress("Executing task 2 of 2", progress: 0.66)

        try await Task.sleep(nanoseconds: UInt64(seconds * Double(NSEC_PER_SEC)))

        await taskRun.updateProgress("Finished all tasks", progress: 1)

        if name == "auth" {
            await taskRun.updateErrorsAndWarnings(errors: 2, warnings: 6)
        }
    }
}
