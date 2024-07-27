//
//  CEWorkspaceSettingsData.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 01.07.24.
//

import Foundation

/// The model of the workspace settings for `CodeEdit` that control the behavior of some functionality at the workspace
/// level like the workspace name or defining tasks.  A `JSON` representation is persisted in the workspace's
/// `./codeedit/settings.json`. file
class CEWorkspaceSettingsData: ObservableObject, Codable {
    @Published var project: ProjectSettings = .init()
    @Published var tasks: [CETask] = []

    init() { }

    enum CodingKeys: CodingKey {
        case project, tasks
    }

    /// Explicit decoder init for setting default values when key is not present in `JSON`
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.project = try container.decodeIfPresent(ProjectSettings.self, forKey: .project) ?? .init()
        self.tasks = try container.decodeIfPresent([CETask].self, forKey: .tasks) ?? []
    }

    /// Encode the instance into the encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !project.isEmpty() {
            try container.encode(project, forKey: .project)
        }
        if !tasks.isEmpty {
            try container.encode(tasks, forKey: .tasks)
        }
    }

    func isEmpty() -> Bool {
        project.isEmpty() && tasks.isEmpty
    }
}
