//
//  ThemePreferences.swift
//  CodeEditModules/Settings
//
//  Created by Nanashi Li on 2022/04/08.
//

import Foundation

extension SettingsData {

    /// A dictionary containing the keys and associated ``Theme/Attributes`` of overridden properties
    ///
    /// ```json
    /// {
    ///   "editor" : {
    ///     "background" : {
    ///       "color" : "#123456"
    ///     },
    ///     ...
    ///   },
    ///   "terminal" : {
    ///     "blue" : {
    ///       "color" : "#1100FF"
    ///     },
    ///     ...
    ///   }
    /// }
    /// ```
    typealias ThemeOverrides = [String: [String: Theme.Attributes]]

    /// The global settings for themes
    struct ThemeSettings: Codable, Hashable, SearchableSettingsPage {

        var searchKeys: [String] {
            [
                "Automatically Change theme based on system appearance",
                "Always use dark terminal appearance",
                "Use theme background",
                "Light Appearance",
                "GitHub Light",
                "Xcode Light",
                "Solarized Light",
                "Solarized Dark",
                "Midnight",
                "Xcode Dark",
                "GitHub Dark"
            ]
            .map { NSLocalizedString($0, comment: "") }
        }

        /// The name of the currently selected dark theme
        var selectedDarkTheme: String = "Default (Dark)"

        /// The name of the currently selected light theme
        var selectedLightTheme: String = "Default (Light)"

        /// The name of the currently selected theme
        var selectedTheme: String?

        /// Use the system background that matches the appearance setting
        var useThemeBackground: Bool = true

        /// Automatically change theme based on system appearance
        var matchAppearance: Bool = true

        /// Dictionary of themes containing overrides
        ///
        /// ```json
        /// {
        ///   "overrides" : {
        ///     "DefaultDark" : {
        ///       "editor" : {
        ///         "background" : {
        ///           "color" : "#123456"
        ///         },
        ///         ...
        ///       },
        ///       "terminal" : {
        ///         "blue" : {
        ///           "color" : "#1100FF"
        ///         },
        ///         ...
        ///       }
        ///       ...
        ///     },
        ///     ...
        ///   },
        ///   ...
        /// }
        /// ```
        var overrides: [String: ThemeOverrides] = [:]

        /// Default initializer
        init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.selectedDarkTheme = try container.decodeIfPresent(
                String.self, forKey: .selectedDarkTheme
            ) ?? selectedDarkTheme
            self.selectedLightTheme = try container.decodeIfPresent(
                String.self, forKey: .selectedLightTheme
            ) ?? selectedLightTheme
            self.selectedTheme = try container.decodeIfPresent(String.self, forKey: .selectedTheme)
            self.useThemeBackground = try container.decodeIfPresent(Bool.self, forKey: .useThemeBackground) ?? true
            self.matchAppearance = try container.decodeIfPresent(
                Bool.self, forKey: .matchAppearance
            ) ?? true
            self.overrides = try container.decodeIfPresent([String: ThemeOverrides].self, forKey: .overrides) ?? [:]
        }
    }
}
