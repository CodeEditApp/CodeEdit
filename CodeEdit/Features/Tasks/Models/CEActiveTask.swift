//
//  CEActiveTask.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 24.06.24.
//

import SwiftUI
import Combine

/// Stores the state of a task once it's executed
class CEActiveTask: ObservableObject, Identifiable, Hashable {
    /// The current progress of the task.
    @Published private(set) var output: String  = ""

    /// The status of the task.
    @Published private(set) var status: CETaskStatus = .notRunning

    /// The name of the associated task.
    @ObservedObject var task: CETask

    var process: Process?
    var outputPipe: Pipe?

    private var cancellables = Set<AnyCancellable>()

    init(task: CETask) {
        self.task = task
        self.process = Process()
        self.outputPipe = Pipe()

        self.task.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }.store(in: &cancellables)
    }

    func run(workspaceURL: URL? = nil) {
        Task {
            // Reconstruct the full command to ensure it executes in the correct directory.
            // Because: CETask only contains information about the relative path.
            let fullCommand: String
            if let workspaceURL = workspaceURL {
                fullCommand = "cd \(workspaceURL.relativePath.escapedDirectory()) && \(task.fullCommand)"
            } else {
                fullCommand = task.fullCommand
            }
            guard let process, let outputPipe else { return }

            await updateTaskStatus(to: .running)
            createStatusTaskNotification()

            process.terminationHandler = { [weak self] capturedProcess in
                if let self {
                    Task {
                        await self.handleProcessFinished(terminationStatus: capturedProcess.terminationStatus)
                    }
                }
            }

            outputPipe.fileHandleForReading.readabilityHandler = { fileHandle in
                if let data = String(bytes: fileHandle.availableData, encoding: .utf8),
                   !data.isEmpty {
                    Task {
                        await self.updateOutput(data)
                    }
                }
            }

            do {
                try Shell.executeCommandWithShell(
                    process: process,
                    command: fullCommand,
                    environmentVariables: self.task.environmentVariablesDictionary,
                    shell: Shell.zsh, // TODO: Let user decide which shell to use
                    outputPipe: outputPipe
                )
            } catch { print(error) }
        }
    }

    func handleProcessFinished(terminationStatus: Int32) async {
        handleTerminationStatus(terminationStatus)

        if terminationStatus == 0 {
            await updateOutput("\nFinished running \(task.name).\n\n")
            await updateTaskStatus(to: .finished)
            updateTaskNotification(
                title: "Finished Running \(task.name)",
                message: "",
                isLoading: false
            )
        } else if terminationStatus == 15 {
            await updateOutput("\n\(task.name) cancelled.\n\n")
            await updateTaskStatus(to: .notRunning)
            updateTaskNotification(
                title: "\(task.name) cancelled",
                message: "",
                isLoading: false
            )
        } else {
            await updateOutput("\nFailed to run \(task.name).\n\n")
            await updateTaskStatus(to: .failed)
            updateTaskNotification(
                title: "Failed Running \(task.name)",
                message: "",
                isLoading: false
            )
        }
        outputPipe?.fileHandleForReading.readabilityHandler = nil

        deleteStatusTaskNotification()
    }

    func renew() {
        if let process {
            if process.isRunning {
                process.terminate()
                process.waitUntilExit()
            }
            self.process = Process()
            outputPipe = Pipe()
        }
    }

    func suspend() {
        if let process, status == .running {
            process.suspend()
            Task {
                await updateTaskStatus(to: .stopped)
            }
        }
    }

    func resume() {
        if let process, status == .stopped {
            process.resume()
            Task {
                await updateTaskStatus(to: .running)
            }
        }
    }

    func clearOutput() {
        output = ""
    }

    private func createStatusTaskNotification() {
        let userInfo: [String: Any] = [
            "id": self.task.id.uuidString,
            "action": "createWithPriority",
            "title": "Running \(self.task.name)",
            "message": "Running your task: \(self.task.name).",
            "isLoading": true
        ]

        NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: userInfo)
    }

    private func deleteStatusTaskNotification() {
        let deleteInfo: [String: Any] = [
            "id": "\(task.id.uuidString)",
            "action": "deleteWithDelay",
            "delay": 3.0
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
        lhs.status == rhs.status &&
        lhs.process == rhs.process &&
        lhs.task == rhs.task
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(output)
        hasher.combine(status)
        hasher.combine(task)
    }

    // OPTIONAL
    func handleTerminationStatus(_ status: Int32) {
        switch status {
        case 0:
            print("Process completed successfully.")
        case 1:
            print("General error.")
        case 2:
            print("Misuse of shell builtins.")
        case 126:
            print("Command invoked cannot execute.")
        case 127:
            print("Command not found.")
        case 128:
            print("Invalid argument to exit.")
        default:
            print("Process ended with exit code \(status).")
        }
    }
}
