//
//  SearchSettings.swift
//  CodeEdit
//
//  Created by Esteban on 12/10/23.
//

import Foundation

public struct SearchSettings: SettingsSection {

    /// The top-level key this section occupies in `settings.json`.
    public static let settingsKey = "search"

    /// List of Glob Patterns that determine which files or directories to ignore
    @CodableDefault<DefaultEmptyGlobPatterns> public var ignoreGlobPatterns: [GlobPattern] = []

    /// Default initializer
    public init() {}
}
