//
//  CEWorkspaceSettingsData.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
//

import SwiftUI
import Foundation

protocol WorkspaceSettingsGroup {
    /// Determine if the settings are changed from the defaults.
    /// Used to check if creating a `.codeedit` folder is necessary on the user's machine.
    func isEmpty() -> Bool
}

/// # Workspace Settings
///
/// The model of the workspace settings for `CodeEdit` that control the behavior of some functionality at the workspace
/// level like the workspace name or defining tasks.  A `JSON` representation is persisted in the workspace's
/// `./codeedit/settings.json`. file
struct CEWorkspaceSettingsData: Codable, Hashable, WorkspaceSettingsGroup {
    /// The project global settings
    var project: ProjectSettings = .init()

    /// The tasks settings
    var tasks: TasksSettings = .init()

    init() {}

    /// Explicit decoder init for setting default values when key is not present in `JSON`
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.project = try container.decodeIfPresent(ProjectSettings.self, forKey: .project) ?? .init()
        self.tasks = try container.decodeIfPresent(TasksSettings.self, forKey: .tasks) ?? .init()
    }

    func propertiesOf(_ name: CEWorkspaceSettingsPage.Name) -> [CEWorkspaceSettingsPage] {
        var settings: [CEWorkspaceSettingsPage] = []

        switch name {
        case .project:
            project.searchKeys.forEach { settings.append(.init(name, isSetting: true, settingName: $0)) }
        case .tasks:
            tasks.searchKeys.forEach { settings.append(.init(name, isSetting: true, settingName: $0)) }
        }

        return settings
    }

    func isEmpty() -> Bool {
        project.isEmpty() && tasks.isEmpty()
    }
}
