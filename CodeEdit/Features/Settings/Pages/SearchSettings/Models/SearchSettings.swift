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
                "Ignore Glob Patterns"
            ]
            .map { NSLocalizedString($0, comment: "") }
        }

        var ignoreGlobPatterns: Array<String> = []
    }
}
