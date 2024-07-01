//
//  CEWorkspaceSettingsData.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
//

import SwiftUI

/// The model of the workspace settings for `CodeEdit` that control the behavior of some functionality at the workspace
/// level like the workspace name or defining tasks.  A `JSON` representation is persisted in the workspace's
/// `./codeedit/settings.json`. file
class CEWorkspaceSettingsData: ObservableObject, Codable, Hashable, WorkspaceSettingsGroup {
    static func == (lhs: CEWorkspaceSettingsData, rhs: CEWorkspaceSettingsData) -> Bool {
        lhs.tasks == rhs.tasks &&
        lhs.project == rhs.project
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(tasks)
        hasher.combine(project)
    }

    /// The project global settings
    @Published var project: ProjectSettings = .init()

    /// The tasks settings
    @Published var tasks: [CETask] = []

    init() {
        print("INITILISED")
    }

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
        try container.encode(project, forKey: .project)
        try container.encode(tasks, forKey: .tasks)
    }

    func propertiesOf(_ name: CEWorkspaceSettingsPage.Name) -> [CEWorkspaceSettingsPage] {
        var settings: [CEWorkspaceSettingsPage] = []
        //        switch name {
        //        case .project:
        //            project.searchKeys.forEach { settings.append(.init(name, isSetting: true, settingName: $0)) }
        //        case .tasks:
        //            tasks.searchKeys.forEach { settings.append(.init(name, isSetting: true, settingName: $0)) }
        //        }

        return settings
    }

    func isEmpty() -> Bool {
        project.isEmpty() && tasks.isEmpty
    }
}

protocol WorkspaceSettingsGroup {
    /// Determine if the settings are changed from the defaults.
    /// Used to check if creating a `.codeedit` folder is necessary on the user's machine.
    func isEmpty() -> Bool
}
