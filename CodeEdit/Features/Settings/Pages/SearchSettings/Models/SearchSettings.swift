//
//  SearchSettings.swift
//  CodeEdit
//
//  Created by Esteban on 12/10/23.
//

import Foundation

extension SettingsData {

    struct SearchSettings: Codable, Hashable, SearchableSettingsPage {

        /// The search keys
        var searchKeys: [String] {
            [
                "Ignore Glob Patterns",
                "Ignore Patterns"
            ]
            .map { NSLocalizedString($0, comment: "") }
        }

        /// List of Glob Patterns that determine which files or directories to ignore
        var ignoreGlobPatterns: [String] = [
            "Testing"
        ]
    }
}
