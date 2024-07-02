//
//  CETask.swift
//  CodeEdit
//
//  Created by Axel Martinez on 2/4/24.
//

import Foundation

/// CodeEdit task that will be executed by the task manager.
class CETask: ObservableObject, Identifiable, Hashable, Codable {
    @Published var id = UUID()
    @Published var name: String = ""
    @Published var target: String = ""
    @Published var workingDirectory: String = ""
    @Published var command: String = ""
    @Published var environmentVariables: [EnvironmentVariable]  = []

    init(target: String, workingDirectory: String) {
        self.target = target
        self.workingDirectory = workingDirectory
    }

    var isInvalid: Bool {
        name.isEmpty ||
        command.isEmpty ||
        target.isEmpty ||
        workingDirectory.isEmpty
    }

    /// Ensures that the environment variables are exported, the shell navigates to the correct folder,
    /// and then executes the specified command.
    var fullCommand: String {
        // Export all necessary environment variables before starting the task
        let environmentVariables = environmentVariables
            .map { "export \($0.key)=\"\($0.value)\"" }
            .joined(separator: " && ")
            .appending(";")

        // Move into the specified folder if needed
        let changeDirectoryCommand = workingDirectory.isEmpty ? "" : "cd \(workingDirectory) && "

        // Construct the full command
        return "\(environmentVariables)\(changeDirectoryCommand)\(command)"
    }

    enum CodingKeys: CodingKey {
        case name
        case target
        case workingDirectory
        case command
        case environmentVariables
    }

    struct EnvironmentVariable: Identifiable, Hashable {
        var id = UUID()
        var key: String = ""
        var value: String = ""

        init() {}

        init(key: String, value: String) {
            self.key = key
            self.value = value
        }
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        target = try container.decode(String.self, forKey: .target)
        workingDirectory = try container.decode(String.self, forKey: .workingDirectory)
        command = try container.decode(String.self, forKey: .command)

        // Decode environment variables from a dictionary-like structure
        if let envDict = try container.decodeIfPresent([String: String].self, forKey: .environmentVariables) {
            environmentVariables = envDict.map { EnvironmentVariable(key: $0.key, value: $0.value) }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(target, forKey: .target)
        try container.encode(workingDirectory, forKey: .workingDirectory)
        try container.encode(command, forKey: .command)

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

extension CETask {
    static func == (lhs: CETask, rhs: CETask) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.target == rhs.target &&
        lhs.workingDirectory == rhs.workingDirectory &&
        lhs.command == rhs.command &&
        lhs.environmentVariables == rhs.environmentVariables
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(target)
        hasher.combine(workingDirectory)
        hasher.combine(command)
        hasher.combine(environmentVariables)
    }
}
