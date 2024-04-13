//
//  CEWorkspaceSettingsData+TasksSettings.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
//

import Foundation
import Collections

extension CEWorkspaceSettingsData {
    /// The tasks  setting
    struct TasksSettings: Codable, Hashable, SearchableSettingsPage {
        var items: [CETask] = []

        var searchKeys: [String] {
            [
                "Tasks"
            ]
                .map { NSLocalizedString($0, comment: "") }
        }

        /// The show live issues behavior of the app
        var enabled: Bool = true

        /// Default initializer
        init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.items = try container.decodeIfPresent(
                [CETask].self,
                forKey: .items
            ) ?? []
            self.enabled = try container.decodeIfPresent(
                Bool.self,
                forKey: .enabled
            ) ?? true
        }
    }
}
