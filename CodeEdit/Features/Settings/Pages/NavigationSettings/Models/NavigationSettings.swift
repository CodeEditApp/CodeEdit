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
        var navigationStyle: NavigationStyle = .openInTabs

        /// Default initializer
        init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.navigationStyle = try container.decodeIfPresent(
                NavigationStyle.self, forKey: .navigationStyle
            ) ?? .openInTabs
        }
    }

    enum NavigationStyle: String, Codable, Hashable {
        case openInTabs
        case openInPlace
    }
}
