//
//  ProjectCEWorkspaceSettings.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
//

import SwiftUI

extension CEWorkspaceSettingsData {
    /// The project setting
    struct ProjectSettings: Codable, Hashable, SearchableSettingsPage {
        var searchKeys: [String] {
            [
                "Project Name",
            ]
            .map { NSLocalizedString($0, comment: "") }
        }

        /// The project name
        var projectName: String = ""

        /// Default initializer
        init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.projectName = try container.decodeIfPresent(
                String.self,
                forKey: .projectName
            ) ?? ""
        }
    }
}
