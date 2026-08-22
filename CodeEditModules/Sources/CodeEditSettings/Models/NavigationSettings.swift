//
//  NavigationSettings.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/4/24.
//

import Foundation

/// The global settings for the terminal emulator
public struct NavigationSettings: SettingsSection {

    /// The top-level key this section occupies in `settings.json`.
    public static let settingsKey = "navigation"

    /// Navigation style used
    @CodableDefault<DefaultNavigationStyle> public var navigationStyle: NavigationStyle = .openInTabs

    /// Default initializer
    public init() {}

    public enum NavigationStyle: String, Codable, Hashable {
        case openInTabs
        case openInPlace
    }
}
