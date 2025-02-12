//
//  GitClient.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 26/11/2022.
//

import Combine
import Foundation
import OSLog

class GitClient {
    enum GitClientError: Error {
        case outputError(String)
        case notGitRepository
        case failedToDecodeURL
        case noRemoteConfigured
        // Status parsing
        case statusParseEarlyEnd
        case invalidStatus(_ char: Character)
        case statusInvalidChangeType(_ type: Character)

        var description: String {
            switch self {
            case .outputError(let string): string
            case .notGitRepository: "Not a git repository"
            case .failedToDecodeURL: "Failed to decode URL"
            case .noRemoteConfigured: "No remote configured"
            case .statusParseEarlyEnd: "Invalid status, found end of string too early"
            case let .invalidStatus(char): "Invalid status received: \(char)"
            case let .statusInvalidChangeType(char): "Status invalid change type: \(char)"
            }
        }
    }

    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "GitClient")

    internal let directoryURL: URL
    internal let shellClient: ShellClient

    private let configClient: GitConfigClient

    init(directoryURL: URL, shellClient: ShellClient) {
        self.directoryURL = directoryURL
        self.shellClient = shellClient
        self.configClient = GitConfigClient(projectURL: directoryURL, shellClient: shellClient)
    }

    func getConfig<T: GitConfigRepresentable>(key: String) async throws -> T? {
        return try await configClient.get(key: key, global: false)
    }

    func setConfig<T: GitConfigRepresentable>(key: String, value: T) async {
        await configClient.set(key: key, value: value, global: false)
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
        "cd \(directoryURL.relativePath.escapedDirectory());git \(command)"
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
