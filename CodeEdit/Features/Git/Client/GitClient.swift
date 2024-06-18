//
//  GitClient.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 26/11/2022.
//

import Combine
import Foundation

class GitClient {
    enum GitClientError: Error {
        case outputError(String)
        case notGitRepository
        case failedToDecodeURL
        case noRemoteConfigured

        var description: String {
            switch self {
            case .outputError(let string): string
            case .notGitRepository: "Not a git repository"
            case .failedToDecodeURL: "Failed to decode URL"
            case .noRemoteConfigured: "No remote configured"
            }
        }
    }

    internal let directoryURL: URL
    internal let shellClient: ShellClient

    init(directoryURL: URL, shellClient: ShellClient) {
        self.directoryURL = directoryURL
        self.shellClient = shellClient
    }

    /// Runs a git command, it will prepend the command with `cd <directoryURL>;git`,
    /// If you need to run "git checkout", pass "checkout" as the command parameter
    internal func run(_ command: String) async throws -> String {
        let output = try shellClient.run(generateCommand(command))
        return try processCommonErrors(output)
    }

    internal typealias LiveCommandStream = AsyncThrowingMapSequence<AsyncThrowingStream<String, Error>, String>

    /// Runs a git command in same way as `run`, but returns a async stream of the output
    internal func runLive(_ command: String) -> LiveCommandStream {
        return runLive(customCommand: generateCommand(command))
    }

    /// Here you can run a custom command, this is needed for git clone
    internal func runLive(customCommand: String) -> LiveCommandStream {
        return shellClient
            .runAsync(customCommand)
            .map { output in
                return try self.processCommonErrors(output)
            }
    }

    private func generateCommand(_ command: String) -> String {
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(command)"
    }

    private func processCommonErrors(_ output: String) throws -> String {
        if output.contains("fatal: not a git repository") {
            throw GitClientError.notGitRepository
        }

        if output.contains("fatal: No remote configured") {
            throw GitClientError.noRemoteConfigured
        }

        if output.hasPrefix("fatal:") {
            throw GitClientError.outputError(output)
        }

        return output
    }
}

internal extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

internal extension String {
    func escapedWhiteSpaces() -> String {
        self.replacingOccurrences(of: " ", with: "\\ ")
    }
}
