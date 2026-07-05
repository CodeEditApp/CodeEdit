//
//  CEWorkspaceSettingsData.swift
//  CodeEditCore
//
//  Created by Tommy Ludwig on 01.07.24.
//

import Foundation

/// The model of the workspace settings for `CodeEdit` that control the behavior of some functionality at the workspace
/// level like the workspace name or defining tasks. A `JSON` representation is persisted in the workspace's
/// `.codeedit/settings.json` file.
public struct CEWorkspaceSettingsData: Codable, Sendable, Equatable {
    public var project: ProjectSettings
    public var tasks: [CETask]

    public init(project: ProjectSettings = .init(), tasks: [CETask] = []) {
        self.project = project
        self.tasks = tasks
    }

    enum CodingKeys: CodingKey {
        case project, tasks
    }

    /// Explicit decoder init for setting default values when key is not present in `JSON`
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.project = try container.decodeIfPresent(ProjectSettings.self, forKey: .project) ?? .init()
        self.tasks = try container.decodeIfPresent([CETask].self, forKey: .tasks) ?? []
    }

    /// Encode the instance into the encoder
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !project.isEmpty() {
            try container.encode(project, forKey: .project)
        }
        if !tasks.isEmpty {
            try container.encode(tasks, forKey: .tasks)
        }
    }

    public func isEmpty() -> Bool {
        project.isEmpty() && tasks.isEmpty
    }
}
