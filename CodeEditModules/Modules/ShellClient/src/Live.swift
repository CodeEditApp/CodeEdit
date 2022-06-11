//
//  Live.swift
//  CodeEditModules/ShellClient
//
//  Created by Marco Carnevali on 27/03/22.
//
import Foundation
import Combine

// TODO: DOCS (Marco Carnevali)
// swiftlint:disable missing_docs
public extension ShellClient {
    static func live() -> Self {
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

        var cancellables: [UUID: AnyCancellable] = [:]

        return ShellClient(
            runLive: { args in
                let subject = PassthroughSubject<String, Never>()
                let (task, pipe) = generateProcessAndPipe(args)
                let outputHandler = pipe.fileHandleForReading
                // wait for the data to come in and then notify
                // the Notification with Name: `NSFileHandleDataAvailable`
                outputHandler.waitForDataInBackgroundAndNotify()
                let id = UUID()
                cancellables[id] = NotificationCenter
                    .default
                    .publisher(for: .NSFileHandleDataAvailable, object: outputHandler)
                    .sink { _ in
                        let data = outputHandler.availableData
                        // swiftlint:disable:next empty_count
                        guard data.count > 0 else {
                            // if no data is available anymore
                            // we should cancel this cancellable
                            // and mark the subject as finished
                            cancellables.removeValue(forKey: id)
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
            }, run: { args in
                let (task, pipe) = generateProcessAndPipe(args)
                try task.run()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                return String(data: data, encoding: .utf8) ?? ""
            }
        )
    }
}
