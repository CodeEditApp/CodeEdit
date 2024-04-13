//
//  CETask.swift
//  CodeEdit
//
//  Created by Axel Martinez on 2/4/24.
//

import SwiftUI

struct CETask: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String = ""
    var target: String = ""
    var workingDirectory: String = ""
    var command: String = ""
    var env: [EnvironmentVariable]  = []

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
        case env
    }
}

struct EnvironmentVariable: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String = ""
    var value: String = ""

    private struct CodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?

        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }

        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
    }

    init() {
    }

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
