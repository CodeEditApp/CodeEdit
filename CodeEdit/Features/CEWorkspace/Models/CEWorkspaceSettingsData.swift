//
//  CEWorkspaceSettingsData.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
//

import SwiftUI
import Foundation

/// # Workspace Settings
///
/// The model structure of settings for `CodeEdit`
///
/// A `JSON` representation is persisted in `~/Library/Application Support/CodeEdit/preference.json`.
/// - Attention: Don't use `UserDefaults` for persisting user accessible settings.
///  If a further setting is needed, extend the struct like ``GeneralSettings``,
///  ``ThemeSettings``,  or ``TerminalSettings`` does.
///
/// - Note: Also make sure to implement the ``init(from:)`` initializer, decoding
///  all properties with
///  [`decodeIfPresent`](https://developer.apple.com/documentation/swift/keyeddecodingcontainer/2921389-decodeifpresent)
///  and providing a default value. Otherwise all settings get overridden.
struct CEWorkspaceSettingsData: Codable, Hashable {
    
    /// The general global settings
    var project: ProjectSettings = .init()

    /// The global settings for accounts
    var tasks: TasksSettings = .init()

    /// Default initializer
    init() {}

    /// Explicit decoder init for setting default values when key is not present in `JSON`
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.project = try container.decodeIfPresent(ProjectSettings.self, forKey: .project) ?? .init()
        self.tasks = try container.decodeIfPresent(TasksSettings.self, forKey: .tasks) ?? .init()
    }

    // swiftlint:disable cyclomatic_complexity
    func propertiesOf(_ name: CEWorkspaceSettingsPage.Name) -> [CEWorkspaceSettingsPage] {
        var settings: [CEWorkspaceSettingsPage] = []

        switch name {
        case .project:
            general.searchKeys.forEach { settings.append(.init(name, isSetting: true, settingName: $0)) }
        case .tasks:
            tasks.searchKeys.forEach { settings.append(.init(name, isSetting: true, settingName: $0)) }
        }

        return settings
    }
    // swiftlint:enable cyclomatic_complexity
}

