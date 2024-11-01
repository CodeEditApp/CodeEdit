//
//  GitConfigClient.swift
//  CodeEdit
//
//  Created by Austin Condiff on 10/31/24.
//

import Foundation

protocol GitConfigRepresentable {
    init?(configValue: String)
    var asConfigValue: String { get }
}

extension Bool: GitConfigRepresentable {
    init?(configValue: String) {
        switch configValue.lowercased() {
        case "true": self = true
        case "false": self = false
        default: return nil
        }
    }

    var asConfigValue: String {
        self ? "true" : "false"
    }
}

extension String: GitConfigRepresentable {
    init?(configValue: String) {
        self = configValue
    }

    var asConfigValue: String {
        "\"\(self)\""
    }
}

class GitConfigClient {
    private let projectURL: URL?
    private let shellClient: ShellClient

    init(projectURL: URL? = nil, shellClient: ShellClient) {
        self.projectURL = projectURL
        self.shellClient = shellClient
    }

    private func runConfigCommand(_ command: String, global: Bool) async throws -> String {
        var fullCommand = "git config"

        if global {
            fullCommand += " --global"
        } else if let projectURL = projectURL {
            fullCommand = "cd \(projectURL.relativePath.escapedWhiteSpaces()); " + fullCommand
        }

        fullCommand += " \(command)"
        return try shellClient.run(fullCommand)
    }

    func get<T: GitConfigRepresentable>(key: String, global: Bool = false) async throws -> T? {
        let output = try await runConfigCommand(key, global: global)
        let trimmedOutput = output.trimmingCharacters(in: .whitespacesAndNewlines)
        return T(configValue: trimmedOutput)
    }

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
