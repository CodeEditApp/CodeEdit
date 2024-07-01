//
//  CETask.swift
//  CodeEdit
//
//  Created by Axel Martinez on 2/4/24.
//

import SwiftUI
import Foundation
import Combine

/// CodeEdit task that will be executed by the task manager.
class CETask: ObservableObject, Identifiable, Hashable, Codable {
    @Published var id = UUID()
    @Published var name: String = ""
    @Published var target: String = ""
    @Published var workingDirectory: String = ""
    @Published var command: String = ""
    @Published var environmentVariables: [EnvironmentVariable]  = []

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
            .map { "export \($0.name)=\"\($0.value)\"" }
            .joined(separator: " && ")
            .appending(";")

        // Move into the specified folder if needed
        let changeDirectoryCommand = workingDirectory.isEmpty ? "" : "cd \(workingDirectory) && "

        // Construct the full command
        return "\(environmentVariables)\(changeDirectoryCommand)\(command)"
    }

    enum CodingKeys: String, CodingKey {
        case name
        case target
        case workingDirectory
        case command
        case environmentVariables
    }

    struct EnvironmentVariable: Identifiable, Hashable, Codable {
        var id = UUID()
        var name: String = ""
        var value: String = ""

        /// Enables encoding the environment variables as a `name`:`value`pair.
        private struct CodingKeys: CodingKey {
            var stringValue: String
            var intValue: Int?

            init?(stringValue: String) {
                self.stringValue = stringValue
                self.intValue = nil
            }

            /// Required by the CodingKey protocol but not being currently used.
            init?(intValue: Int) {
                self.stringValue = "\(intValue)"
                self.intValue = intValue
            }
        }

        init() {}

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            for key in container.allKeys {
                name = key.stringValue
                value = try container.decode(String.self, forKey: key)
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: CodingKeys(stringValue: name)!)
        }
    }

    init(target: String, workingDirectory: String) {
        self.target = target
        self.workingDirectory = workingDirectory
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        target = try container.decode(String.self, forKey: .target)
        workingDirectory = try container.decode(String.self, forKey: .workingDirectory)
        command = try container.decode(String.self, forKey: .command)
        environmentVariables = try container.decode([EnvironmentVariable].self, forKey: .environmentVariables)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(target, forKey: .target)
        try container.encode(workingDirectory, forKey: .workingDirectory)
        try container.encode(command, forKey: .command)
        try container.encode(environmentVariables, forKey: .environmentVariables)
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

    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(target)
        hasher.combine(workingDirectory)
        hasher.combine(command)
        hasher.combine(environmentVariables)
    }
}


class CETask2: ObservableObject, Identifiable, Hashable, Codable {
    var id = UUID()
    @Published var name: String = ""
    @Published var target: String = ""
    @Published var workingDirectory: String = ""
    @Published var command: String = ""
    @Published var environmentVariables: [String: String]  = [:]

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

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case target
        case workingDirectory
        case command
        case environmentVariables
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        target = try container.decode(String.self, forKey: .target)
        workingDirectory = try container.decode(String.self, forKey: .workingDirectory)
        command = try container.decode(String.self, forKey: .command)
        environmentVariables = try container.decode([String: String].self, forKey: .environmentVariables)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(target, forKey: .target)
        try container.encode(workingDirectory, forKey: .workingDirectory)
        try container.encode(command, forKey: .command)
        try container.encode(environmentVariables, forKey: .environmentVariables)
    }
}
extension CETask2 {
    static func == (lhs: CETask2, rhs: CETask2) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.target == rhs.target &&
        lhs.workingDirectory == rhs.workingDirectory &&
        lhs.command == rhs.command &&
        lhs.environmentVariables == rhs.environmentVariables
    }

    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(target)
        hasher.combine(workingDirectory)
        hasher.combine(command)
        hasher.combine(environmentVariables)
    }
}

class CEActiveTask2: ObservableObject {
    @ObservedObject var runConfiguration: CETask2

    @Published private(set) var output: String  = ""
    @Published private(set) var status: CETaskStatus = .notRunning

    init(runConfiguration: CETask2, output: String, status: CETaskStatus) {
        self.runConfiguration = runConfiguration
        self.output = output
        self.status = status
    }
}
