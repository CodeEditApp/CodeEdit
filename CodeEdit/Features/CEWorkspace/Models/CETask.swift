//
//  CETask.swift
//  CodeEdit
//
//  Created by Axel Martinez on 2/4/24.
//

import SwiftUI

/// CodeEdit task that will be executed by the task manager.
struct CETask: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String = ""
    var target: String = ""
    var workingDirectory: String = ""
    var command: String = ""
    var environmentVariables: [EnvironmentVariable]  = []

    var isInvalid: Bool {
        name.isEmpty ||
        command.isEmpty ||
        target.isEmpty ||
        workingDirectory.isEmpty
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
}
