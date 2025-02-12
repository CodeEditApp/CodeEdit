//
//  GitConfigClient.swift
//  CodeEdit
//
//  Created by Austin Condiff on 10/31/24.
//

import Foundation

/// A client for managing Git configuration settings.
/// Provides methods to read and write Git configuration values at both
/// project and global levels.
class GitConfigClient {
    private let projectURL: URL?
    private let shellClient: ShellClient

    /// Initializes a new GitConfigClient.
    /// - Parameters:
    ///   - projectURL: The project directory URL (if any).
    ///   - shellClient: The client responsible for executing shell commands.
    init(projectURL: URL? = nil, shellClient: ShellClient) {
        self.projectURL = projectURL
        self.shellClient = shellClient
    }

    /// Runs a Git configuration command.
    /// - Parameters:
    ///   - command: The Git command to execute.
    ///   - global: Whether to apply the command globally or locally.
    /// - Returns: The command output as a string.
    private func runConfigCommand(_ command: String, global: Bool) async throws -> String {
        var fullCommand = "git config"

        if global {
            fullCommand += " --global"
        } else if let projectURL = projectURL {
            fullCommand = "cd \(projectURL.relativePath.escapedDirectory()); " + fullCommand
        }

        fullCommand += " \(command)"
        return try shellClient.run(fullCommand)
    }

    /// Retrieves a Git configuration value.
    /// - Parameters:
    ///   - key: The configuration key to retrieve.
    ///   - global: Whether to retrieve the value globally or locally.
    /// - Returns: The value as a type conforming to `GitConfigRepresentable`, or `nil` if not found.
    func get<T: GitConfigRepresentable>(key: String, global: Bool = false) async throws -> T? {
        let output = try await runConfigCommand(key, global: global)
        let trimmedOutput = output.trimmingCharacters(in: .whitespacesAndNewlines)
        return T(configValue: trimmedOutput)
    }

    /// Sets a Git configuration value.
    /// - Parameters:
    ///   - key: The configuration key to set.
    ///   - value: The value to set, conforming to `GitConfigRepresentable`.
    ///   - global: Whether to set the value globally or locally.
    func set<T: GitConfigRepresentable>(key: String, value: T, global: Bool = false) async {
        let shouldUnset: Bool
        if let boolValue = value as? Bool {
            shouldUnset = !boolValue
        } else if let stringValue = value as? String {
            shouldUnset = stringValue.isEmpty
        } else {
            shouldUnset = false
        }

        let commandString = shouldUnset ? "--unset \(key)" : "\(key) \(value.asConfigValue)"

        do {
            _ = try await runConfigCommand(commandString, global: global)
        } catch {
            print("Failed to set \(key): \(error)")
        }
    }
}
