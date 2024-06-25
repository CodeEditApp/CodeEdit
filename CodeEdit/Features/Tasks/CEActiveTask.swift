//
//  CEActiveTask.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 24.06.24.
//

import Foundation

/// Stores the state of a task once it's executed
class CEActiveTask: ObservableObject, Identifiable, Hashable {
    /// The current progress of the task.
    @Published private(set) var output: String  = ""

    /// The status of the task.
    @Published private(set) var status: CETaskStatus = .stopped

    /// The name of the associated task.
    let task: CETask

    var process: Process?
    var outputPipe: Pipe?

    init(task: CETask) {
        self.task = task
        self.process = Process()
        self.outputPipe = Pipe()
    }

    func run() {
        let command = task.fullCommand
        guard let process, let outputPipe else {
            return
        }

        Task {
            await updateTaskStatus(to: .running)
        }

        createStatusTaskNotification()

        process.terminationHandler = { [weak self] _ in
            self?.outputPipe?.fileHandleForReading.readabilityHandler = nil
            self?.updateTaskNotification(
                title: "Finished Running: \(self?.task.name ?? "Unknown")",
                message: "",
                isLoading: false
            )
            Task { [weak self] in
                await self?.updateOutput("\nFinished running \(self?.task.name ?? "Task").\n\n")
                await self?.updateTaskStatus(to: .finished)
            }
        }

        Task.detached {
            outputPipe.fileHandleForReading.readabilityHandler = { fileHandle in
                let data = fileHandle.availableData
                if let outputString = String(data: data, encoding: .utf8), !outputString.isEmpty {
                    print(outputString)
                    Task {
                        await self.updateOutput(outputString)
                    }
                }
            }
            do {
                try TaskShell.executeCommandWithShell(
                    process: process,
                    command: command,
                    shell: TaskShell.zsh,
                    outputPipe: outputPipe
                )
            } catch {
                self.updateTaskNotification(
                    title: "Task: \(self.task.name) failed",
                    message: error.localizedDescription,
                    isLoading: false
                )
                await self.updateTaskStatus(to: .finished)
                print(error)
            }
        }
    }

    func renew() {
        if process?.isRunning ?? false {
            process!.terminate()
        }
        process = Process()
        outputPipe = Pipe()
    }

    func clearOutput() async {
        await MainActor.run {
            output = ""
        }
    }

    private func createStatusTaskNotification() {
        let userInfo: [String: Any] = [
            "id": self.task.id.uuidString,
            "action": "createWithPriority",
            "title": "Running: \(self.task.name)",
            "message": "Running your task: \(self.task.name).",
            "isLoading": true
        ]

        NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: userInfo)
    }

    private func deleteStatusTaskNotification() {
        let deleteInfo = [
            "id": "\(task.id.uuidString)",
            "action": "delete",
        ]

        NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: deleteInfo)
    }

    private func updateTaskNotification(title: String? = nil, message: String? = nil, isLoading: Bool? = nil) {
        var userInfo: [String: Any] = [
            "id": task.id.uuidString,
            "action": "update"
        ]
        if let title {
            userInfo["title"] = title
        }
        if let message {
            userInfo["message"] = message
        }
        if let isLoading {
            userInfo["isLoading"] = isLoading
        }

        NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: userInfo)
    }

    private func updateTaskStatus(to taskStatus: CETaskStatus) async {
        await MainActor.run {
            self.status = taskStatus
        }
    }

    /// Updates the progress and output values on the main thread`
    private func updateOutput(_ output: String) async {
        await MainActor.run {
            self.output += output
        }
    }

    static func == (lhs: CEActiveTask, rhs: CEActiveTask) -> Bool {
        return lhs.output == rhs.output &&
        lhs.status == rhs.status
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(output)
        hasher.combine(status)
    }
}
