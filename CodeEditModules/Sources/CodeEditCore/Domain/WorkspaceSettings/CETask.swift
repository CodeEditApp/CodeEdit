//
//  CETask.swift
//  CodeEditCore
//
//  Created by Axel Martinez on 2/4/24.
//

import Foundation

/// CodeEdit task that will be executed by the task manager.
public struct CETask: Identifiable, Hashable, Codable, Sendable {
    public var id = UUID()
    public var name: String
    public var target: String
    public var workingDirectory: String
    public var command: String
    public var environmentVariables: [EnvironmentVariable]

    public init(
        name: String = "",
        target: String = "",
        workingDirectory: String = "",
        command: String = "",
        environmentVariables: [CETask.EnvironmentVariable] = []
    ) {
        self.name = name
        self.target = target
        self.workingDirectory = workingDirectory
        self.command = command
        self.environmentVariables = environmentVariables
    }

    public init(target: String) {
        self.name = ""
        self.target = target
        self.workingDirectory = ""
        self.command = ""
        self.environmentVariables = []
    }

    public var isInvalid: Bool {
        name.isEmpty ||
        command.isEmpty
    }

    /// Ensures that the shell navigates to the correct folder, and then executes the specified command.
    public var fullCommand: String {
        // Move into the specified folder if needed
        let changeDirectoryCommand = workingDirectory.isEmpty ? "" : "cd \(workingDirectory.escapedDirectory()) && "

        // Construct the full command
        return "\(changeDirectoryCommand)\(command)"
    }

    /// Converts an array of `EnvironmentVariable` to a dictionary.
    ///
    /// - Returns: A dictionary with the environment variable keys and values.
    public var environmentVariablesDictionary: [String: String] {
        return environmentVariables.reduce(into: [String: String]()) { result, environmentVariable in
            result[environmentVariable.key] = environmentVariable.value
        }
    }

    enum CodingKeys: CodingKey {
        case name
        case target
        case workingDirectory
        case command
        case environmentVariables
    }

    public struct EnvironmentVariable: Identifiable, Hashable, Sendable {
        public var id = UUID()
        public var key: String = ""
        public var value: String = ""

        public init() {}

        public init(key: String, value: String) {
            self.key = key
            self.value = value
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        target = try container.decodeIfPresent(String.self, forKey: .target) ?? ""
        workingDirectory = try container.decodeIfPresent(String.self, forKey: .workingDirectory) ?? ""
        command = try container.decode(String.self, forKey: .command)

        // Decode environment variables from a dictionary-like structure
        if let envDict = try container.decodeIfPresent([String: String].self, forKey: .environmentVariables) {
            environmentVariables = envDict.map { EnvironmentVariable(key: $0.key, value: $0.value) }
        } else {
            environmentVariables = []
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !name.isEmpty {
            try container.encode(name, forKey: .name)
        }
        if !target.isEmpty && target != "My Mac" {
            try container.encode(target, forKey: .target)
        }

        // TODO: Only save if it isn't the workspaces default directory
        if !workingDirectory.isEmpty {
            try container.encode(workingDirectory, forKey: .workingDirectory)
        }
        if !command.isEmpty {
            try container.encode(command, forKey: .command)
        }

        // Encode environment variables as a dictionary-like structure
        if !environmentVariables.isEmpty {
            var envDict = [String: String]()
            for variable in environmentVariables {
                envDict[variable.key] = variable.value
            }
            try container.encode(envDict, forKey: .environmentVariables)
        }
    }
}
