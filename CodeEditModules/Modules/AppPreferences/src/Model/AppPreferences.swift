//
//  AppPreferences.swift
//  
//
//  Created by Lukas Pistrol on 01.04.22.
//

import SwiftUI

/// # AppPreferences
///
/// The model structure of settings for `CodeEdit`
///
/// A `JSON` representation is persisted in `~/.codeedit/preference.json`.
/// - Attention: Don't use `UserDefaults` for persisting user accessible settings.
///  If a further setting is needed, extend the struct like ``GeneralPreferences``,
///  ``ThemePreferences``,  or ``TerminalPreferences`` does.
///
/// - Note: Also make sure to implement the ``init(from:)`` initializer, decoding
///  all properties with ``decodeIfPresent(_:forKey:)`` and providing a default
///  value. Otherwise all settings get overridden.
public struct AppPreferences: Codable {

    /// The general global setting
    public var general: GeneralPreferences = .init()

    /// The global settings for themes
    public var theme: ThemePreferences = .init()

    /// The global settings for the terminal emulator
    public var terminal: TerminalPreferences = .init()

    /// The global settings for text editing
    public var textEditing: TextEditingPreferences = .init()

    /// Default initializer
    public init() {}

    /// Explicit decoder init for setting default values when key is not present in `JSON`
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.general = try container.decodeIfPresent(GeneralPreferences.self, forKey: .general) ?? .init()
        self.theme = try container.decodeIfPresent(ThemePreferences.self, forKey: .theme) ?? .init()
        self.terminal = try container.decodeIfPresent(TerminalPreferences.self, forKey: .terminal) ?? .init()
        self.textEditing = try container.decodeIfPresent(TextEditingPreferences.self, forKey: .textEditing) ?? .init()
    }

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

        /// The size of the project navigators rows.
        public var projectNavigatorSize: ProjectNavigatorSize = .medium

        /// Default initializer
        public init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.appAppearance = try container.decodeIfPresent(Appearances.self, forKey: .appAppearance) ?? .system
            self.fileIconStyle = try container.decodeIfPresent(FileIconStyle.self, forKey: .fileIconStyle) ?? .color
            self.reopenBehavior = try container.decodeIfPresent(ReopenBehavior.self,
                                                                forKey: .reopenBehavior) ?? .welcome
            self.projectNavigatorSize = try container.decodeIfPresent(ProjectNavigatorSize.self,
                                                                      forKey: .projectNavigatorSize) ?? .medium
        }
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

    /// The size of the project navigators rows.
    ///
    /// To match Xcode's settings the row height should be:
    /// * ``small``: `20pt` (fontSize: `11pt`)
    /// * ``medium``: `22pt` (fontSize: `13pt`)
    /// * ``small``: `24pt` (fontSize: `14pt`)
    ///
    /// - note: This should be implemented for all lists in a `NavigatorSidebar`
    enum ProjectNavigatorSize: String, Codable {
        case small
        case medium
        case large
    }

}

public extension AppPreferences {

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
    struct ThemePreferences: Codable {

        /// The name of the currently selected theme
        public var selectedTheme: String?

        /// Use the system background that matches the appearance setting
        public var useThemeBackground: Bool = false

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
        public var overrides: [String: ThemeOverrides] = [:]

        /// Default initializer
        public init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.selectedTheme = try container.decodeIfPresent(String.self, forKey: .selectedTheme)
            self.useThemeBackground = try container.decodeIfPresent(Bool.self, forKey: .useThemeBackground) ?? false
            self.overrides = try container.decodeIfPresent([String: ThemeOverrides].self, forKey: .overrides) ?? [:]
        }
    }

}

public extension AppPreferences {

    /// The global settings for the terminal emulator
    struct TerminalPreferences: Codable {

        /// If true terminal appearance will always be `dark`. Otherwise it adapts to the system setting.
        public var darkAppearance: Bool = false

        /// If true, the terminal treats the `Option` key as the `Meta` key
        public var optionAsMeta: Bool = false

        /// The selected shell to use.
        public var shell: TerminalShell = .system

        /// The font to use in terminal.
        public var font: TerminalFont = .init()

        /// Default initializer
        public init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.darkAppearance = try container.decodeIfPresent(Bool.self, forKey: .darkAppearance) ?? false
            self.optionAsMeta = try container.decodeIfPresent(Bool.self, forKey: .optionAsMeta) ?? false
            self.shell = try container.decodeIfPresent(TerminalShell.self, forKey: .shell) ?? .system
            self.font = try container.decodeIfPresent(TerminalFont.self, forKey: .font) ?? .init()
        }
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
        public var size: Int = 11

        /// The name of the custom font
        public var name: String = "SF-MonoMedium"

        /// Default initializer
        public init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.customFont = try container.decodeIfPresent(Bool.self, forKey: .customFont) ?? false
            self.size = try container.decodeIfPresent(Int.self, forKey: .size) ?? 11
            self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "SF-MonoMedium"
        }
    }
}

public extension AppPreferences {

    /// The global settings for text editing
    struct TextEditingPreferences: Codable {
        /// An integer indicating how many spaces a `tab` will generate
        public var defaultTabWidth: Int = 4

        /// The font to use in editor.
        public var font: EditorFont = .init()

        /// Default initializer
        public init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.defaultTabWidth = try container.decodeIfPresent(Int.self, forKey: .defaultTabWidth) ?? 4
            self.font = try container.decodeIfPresent(EditorFont.self, forKey: .font) ?? .init()
        }
    }

    struct EditorFont: Codable {
        /// Indicates whether or not to use a custom font
        public var customFont: Bool = false

        /// The font size for the custom font
        public var size: Int = 11

        /// The name of the custom font
        public var name: String = "SF-MonoMedium"

        /// Default initializer
        public init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.customFont = try container.decodeIfPresent(Bool.self, forKey: .customFont) ?? false
            self.size = try container.decodeIfPresent(Int.self, forKey: .size) ?? 11
            self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "SF-MonoMedium"
        }
    }
}
