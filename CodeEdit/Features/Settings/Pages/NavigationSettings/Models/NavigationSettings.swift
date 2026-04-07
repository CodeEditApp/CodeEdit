//
//  NavigationSettings.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/4/24.
//

import Foundation

extension SettingsData {

    /// The global settings for the terminal emulator
    struct NavigationSettings: Codable, Hashable, SearchableSettingsPage {

        /// The search keys
        var searchKeys: [String] {
            [
                "Navigation Style",
            ]
            .map { NSLocalizedString($0, comment: "") }
        }

        /// Navigation style used
        @CodableDefault<DefaultNavigationStyle> var navigationStyle: NavigationStyle = .openInTabs

        /// Default initializer
        init() {}
    }

    enum NavigationStyle: String, Codable, Hashable {
        case openInTabs
        case openInPlace
    }
}
