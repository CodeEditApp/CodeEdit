//
//  CEWorkspaceSettingsData+ProjectSettings.swift
//  CodeEditCore
//
//  Created by Axel Martinez on 27/3/24.
//

import Foundation

public struct ProjectSettings: Codable, Sendable, Equatable {
    public var projectName: String = ""

    public init() {}

    /// Explicit decoder init for setting default values when key is not present in `JSON`
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.projectName = try container.decodeIfPresent(String.self, forKey: .projectName) ?? ""
    }

    public func isEmpty() -> Bool {
        projectName == ""
    }
}
