//
//  TerminalPreferences.swift
//  CodeEditModules/Settings
//
//  Created by Nanashi Li on 2022/04/08.
//

import Foundation

extension SettingsData {

    /// The global settings for the terminal emulator
    struct TerminalPreferences: Codable {

        /// If true terminal will use editor theme.
        var useEditorTheme: Bool = true

        /// If true terminal appearance will always be `dark`. Otherwise it adapts to the system setting.
        var darkAppearance: Bool = false

        /// If true, the terminal uses the background color of the theme, otherwise it is clear
        var useThemeBackground: Bool = true

        /// If true, the terminal treats the `Option` key as the `Meta` key
        var optionAsMeta: Bool = false

        /// The selected shell to use.
        var shell: TerminalShell = .system

        /// The font to use in terminal.
        var font: TerminalFont = .init()

        // The cursor style to use in terminal
        var cursorStyle: TerminalCursorStyle = .block

        // Toggle for blinking cursor or not
        var cursorBlink: Bool = false

        /// Default initializer
        init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.darkAppearance = try container.decodeIfPresent(Bool.self, forKey: .darkAppearance) ?? false
            self.optionAsMeta = try container.decodeIfPresent(Bool.self, forKey: .optionAsMeta) ?? false
            self.shell = try container.decodeIfPresent(TerminalShell.self, forKey: .shell) ?? .system
            self.font = try container.decodeIfPresent(TerminalFont.self, forKey: .font) ?? .init()
            self.cursorStyle = try container.decodeIfPresent(
                TerminalCursorStyle.self,
                forKey: .cursorStyle
            ) ?? .block
            self.cursorBlink = try container.decodeIfPresent(Bool.self, forKey: .cursorBlink) ?? false
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

    enum TerminalCursorStyle: String, Codable {
        case block
        case underline
        case bar
    }

    struct TerminalFont: Codable {
        /// Indicates whether or not to use a custom font
        var customFont: Bool = false

        /// The font size for the custom font
        var size: Int = 12

        /// The name of the custom font
        var name: String = "SFMono-Medium"

        /// Default initializer
        init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.customFont = try container.decodeIfPresent(Bool.self, forKey: .customFont) ?? false
            self.size = try container.decodeIfPresent(Int.self, forKey: .size) ?? 11
            self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "SFMono-Medium"
        }
    }
}
