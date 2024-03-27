//
//  TaskManager.swift
//  CodeEdit
//
//  Created by Axel Martinez on 2/2/24.
//

import Foundation

/// This class handles the execution of tasks
final class TaskManager: ObservableObject {
    @Published var activeTask: (any CETask)?
    @Published var activeTaskRun: CETaskRun?

    init() {
        self.activeTask = getTasks().first
    }

    /// Gets the current available tasks
    func getTasks() -> [any CETask] {
        // TODO: Replace with actual tasks
        return [
            TestTask(name: "dev"),
            TestTask(name: "backend"),
            TestTask(name: "auth"),
            TestTask(name: "test")
        ]
    }

    /// Executes the active task
    func executeActiveTask() {
        guard let activeTask = activeTask else { return }

        activeTaskRun = CETaskRun(task: activeTask)

        guard let run = activeTaskRun else { return }

        Task {
            try await run.start()
        }
    }
}
