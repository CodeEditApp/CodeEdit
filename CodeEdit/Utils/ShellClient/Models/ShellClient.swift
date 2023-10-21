//
//  ShellClient.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 25/11/2022.
//

import Combine
import Foundation

/// Shell Client
/// Run commands in shell
class ShellClient {
    /// Generate a process and pipe to run commands
    /// - Parameter args: commands to run
    /// - Returns: command output
    func generateProcessAndPipe(_ args: [String]) -> (Process, Pipe) {
        var arguments = ["-c"]
        arguments.append(contentsOf: args)
        let task = Process()
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = arguments
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        return (task, pipe)
    }

    /// Cancellable tasks
    var cancellables: [UUID: AnyCancellable] = [:]

    /// Run a command
    /// - Parameter args: command to run
    /// - Returns: command output
    @discardableResult
    func run(_ args: String...) throws -> String {
        let (task, pipe) = generateProcessAndPipe(args)
        try task.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }

    /// Run a command with Publisher
    /// - Parameter args: command to run
    /// - Returns: command output
    @discardableResult
    func runLive(_ args: String...) -> AnyPublisher<String, Never> {
        let subject = PassthroughSubject<String, Never>()
        let (task, pipe) = generateProcessAndPipe(args)
        let outputHandler = pipe.fileHandleForReading
        // wait for the data to come in and then notify
        // the Notification with Name: `NSFileHandleDataAvailable`
        outputHandler.waitForDataInBackgroundAndNotify()
        let id = UUID()
        self.cancellables[id] = NotificationCenter
            .default
            .publisher(for: .NSFileHandleDataAvailable, object: outputHandler)
            .sink { _ in
                let data = outputHandler.availableData
                guard !data.isEmpty else {
                    // if no data is available anymore
                    // we should cancel this cancellable
                    // and mark the subject as finished
                    self.cancellables.removeValue(forKey: id)
                    subject.send(completion: .finished)
                    return
                }
                if let line = String(data: data, encoding: .utf8)?
                    .split(whereSeparator: \.isNewline) {
                    line
                        .map(String.init)
                        .forEach(subject.send(_:))
                }
                outputHandler.waitForDataInBackgroundAndNotify()
            }
        task.launch()
        return subject.eraseToAnyPublisher()
    }

    /// Run a command with AsyncStream
    /// - Parameter args: command to run
    /// - Returns: async stream of command output
    func runAsync(_ args: String...) -> AsyncThrowingStream<String, Error> {
        let (task, pipe) = generateProcessAndPipe(args)

        return AsyncThrowingStream { continuation in
            pipe.fileHandleForReading.readabilityHandler = { [unowned pipe] fileHandle in
                let data = fileHandle.availableData
                if !data.isEmpty {
                    if let line = String(data: data, encoding: .utf8)?.split(whereSeparator: \.isNewline) {
                        line.map(String.init).forEach({ continuation.yield($0) })
                    }
                } else {
                    if !task.isRunning && task.terminationStatus != 0 {
                        continuation.finish(
                            throwing: NSError(domain: "ShellClient", code: Int(task.terminationStatus))
                        )
                    } else {
                        continuation.finish()
                    }

                    // Clean up the handler to prevent repeated calls and continuation finishes for the same
                    // process.
                    pipe.fileHandleForReading.readabilityHandler = nil
                }
            }

            do {
                try task.run()
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }

    /// Shell client
    /// - Returns: description
    static func live() -> ShellClient {
        return ShellClient()
    }
}
