//
//  ProjectCEWorkspaceSettings.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
//

import SwiftUI

extension CEWorkspaceSettingsData {
    /// Workspace settings for the project tab.
    struct ProjectSettings: Codable, Hashable, SearchableSettingsPage, WorkspaceSettingsGroup {
        var searchKeys: [String] {
            [
                "Project Name",
            ]
            .map { NSLocalizedString($0, comment: "") }
        }

        var projectName: String = ""

        init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.projectName = try container.decodeIfPresent(String.self, forKey: .projectName) ?? ""
        }

        func isEmpty() -> Bool {
            projectName == ""
        }
    }
}
