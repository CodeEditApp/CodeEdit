//
//  SearchSettings.swift
//  CodeEdit
//
//  Created by Esteban on 12/10/23.
//

import Foundation

extension SettingsData {
    public struct SearchSettings: Codable, Hashable {

        /// List of Glob Patterns that determine which files or directories to ignore
        @CodableDefault<DefaultEmptyGlobPatterns> public var ignoreGlobPatterns: [GlobPattern] = []

        /// Default initializer
        public init() {}
    }
}
