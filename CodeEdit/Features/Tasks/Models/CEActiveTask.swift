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

    /// Reference to the workspace that owns this task
    weak var workspace: WorkspaceDocument?

    /// The activity associated with this task
    private var activity: CEActivity?

    var process: Process?
    var outputPipe: Pipe?

    private var cancellables = Set<AnyCancellable>()

    init(task: CETask, workspace: WorkspaceDocument?) {
        self.task = task
        self.workspace = workspace
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
            createStatusActivity()

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
            updateActivity(
                title: "Finished Running \(task.name)",
                message: "",
                isLoading: false
            )
        } else if terminationStatus == 15 {
            await updateOutput("\n\(task.name) cancelled.\n\n")
            await updateTaskStatus(to: .notRunning)
            updateActivity(
                title: "\(task.name) cancelled",
                message: "",
                isLoading: false
            )
        } else {
            await updateOutput("\nFailed to run \(task.name).\n\n")
            await updateTaskStatus(to: .failed)
            updateActivity(
                title: "Failed Running \(task.name)",
                message: "",
                isLoading: false
            )
        }
        outputPipe?.fileHandleForReading.readabilityHandler = nil

        deleteStatusActivity()
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

    private func createStatusActivity() {
        activity = workspace?.activityManager.post(
            priority: true,
            title: "Running \(self.task.name)",
            message: "Running your task: \(self.task.name).",
            isLoading: true
        )
    }

    private func deleteStatusActivity() {
        if let activityId = activity?.id {
            workspace?.activityManager.delete(
                id: activityId,
                delay: 3.0
            )
        }
    }

    private func updateActivity(title: String? = nil, message: String? = nil, isLoading: Bool? = nil) {
        if let activityId = activity?.id {
            workspace?.activityManager.update(
                id: activityId,
                title: title,
                message: message,
                isLoading: isLoading
            )
        }
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
