//
//  CEWorkspaceSettingsData+TasksSettings.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
//

import Foundation
import Collections

extension CEWorkspaceSettingsData {
    /// Workspace settings for the tasks tab.
    struct TasksSettings: Codable, Hashable, SearchableSettingsPage, WorkspaceSettingsGroup {
        var items: [CETask] = []

        var searchKeys: [String] {
            [
                "Tasks"
            ]
                .map { NSLocalizedString($0, comment: "") }
        }

        /// The tasks functionality behavior of the app
        var enabled: Bool = true

        init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.items = try container.decodeIfPresent([CETask].self, forKey: .items) ?? []
            self.enabled = try container.decodeIfPresent(Bool.self, forKey: .enabled) ?? true
        }

        func isEmpty() -> Bool {
            items.isEmpty && enabled == true
        }
    }
}
