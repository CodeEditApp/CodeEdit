//
//  SearchSettings.swift
//  CodeEdit
//
//  Created by Esteban on 12/10/23.
//

import Foundation

extension SettingsData {
    struct SearchSettings: Codable, Hashable {

        /// List of Glob Patterns that determine which files or directories to ignore
        @CodableDefault<DefaultEmptyGlobPatterns> var ignoreGlobPatterns: [GlobPattern] = []

        /// Default initializer
        init() {}
    }
}
