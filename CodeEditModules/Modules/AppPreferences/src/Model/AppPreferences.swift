//
//  File.swift
//  
//
//  Created by Lukas Pistrol on 01.04.22.
//

import SwiftUI

public struct AppPreferences: Codable {

    /// The general global setting
    public var general: GeneralPreferences = .init()

    /// The global settings for themes
    public var theme: ThemePreferences = .init()

    /// The global settings for the terminal emulator
    public var terminal: TerminalPreferences = .init()

    /// The global settings for text editing
    public var textEditing: TextEditingPreferences = .init()

}

public extension AppPreferences {

    /// The general global setting
    struct GeneralPreferences: Codable {

        /// The appearance of the app
        public var appAppearance: Appearances = .system

        /// The style for file icons
        public var fileIconStyle: FileIconStyle = .color

        /// The reopen behavior of the app
        public var reopenBehavior: ReopenBehavior = .welcome
    }

    /// The appearance of the app
    /// - **system**: uses the system appearance
    /// - **dark**: always uses dark appearance
    /// - **light**: always uses light appearance
    enum Appearances: String, Codable {
        case system
        case light
        case dark

        /// Applies the selected appearance
        public func applyAppearance() {
            switch self {
            case .system:
                NSApp.appearance = nil

            case .dark:
                NSApp.appearance = .init(named: .darkAqua)

            case .light:
                NSApp.appearance = .init(named: .aqua)
            }
        }
    }

    /// The style for file icons
    /// - **color**: File icons appear in their default colors
    /// - **monochrome**: File icons appear monochromatic
    enum FileIconStyle: String, Codable {
        case color
        case monochrome
    }

    /// The reopen behavior of the app
    /// - **welcome**: On restart the app will show the welcome screen
    /// - **openPanel**: On restart the app will show an open panel
    /// - **newDocument**: On restart a new empty document will be created
    enum ReopenBehavior: String, Codable {
        case welcome
        case openPanel
        case newDocument
    }

}

public extension AppPreferences {

    /// A dictionary containing the keys and associated ``Theme/Attributes`` of overridden properties
    typealias ThemeOverrides = [String: Theme.Attributes]

    /// The global settings for themes
    struct ThemePreferences: Codable {

        /// The name of the currently selected theme
        public var selectedTheme: String?

        /// Use the system background that matches the appearance setting
        public var useThemeBackground: Bool = false

        /// Dictionary of themes containing overrides
        ///
        /// ```json
        /// "overrides" : {
        ///   "DefaultDark" : {
        ///     "background" : {
        ///       "color" : "#123456"
        ///     },
        ///     ...
        ///   },
        ///   ...
        /// },
        /// ```
        public var overrides: [String: ThemeOverrides] = [:]
    }

}

public extension AppPreferences {

    /// The global settings for the terminal emulator
    struct TerminalPreferences: Codable {
        /// If true terminal appearance will always be `dark`. Otherwise it adapts to the system setting.
        public var darkAppearance: Bool = false

        /// The selected shell to use.
        public var shell: TerminalShell = .system

        /// The font to use in terminal.
        public var font: TerminalFont = .init()
    }

    /// The shell options.
    /// - **bash**: uses the default bash shell
    /// - **zsh**: uses the ZSH shell
    /// - **system**: uses the system default shell (most likely ZSH)
    enum TerminalShell: String, Codable {
        case bash
        case zsh
        case system
    }

    struct TerminalFont: Codable {
        /// Indicates whether or not to use a custom font
        public var customFont: Bool = false

        /// The font size for the custom font
        public var size: Int?

        /// The name of the custom font
        public var name: String?
    }
}

public extension AppPreferences {

    /// The global settings for text editing
    struct TextEditingPreferences: Codable {
        /// An integer indicating how many spaces a `tab` will generate
        public var defaultTabWidth: Int = 4
    }
}
