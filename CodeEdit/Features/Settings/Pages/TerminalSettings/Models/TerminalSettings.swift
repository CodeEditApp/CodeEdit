//
//  TerminalPreferences.swift
//  CodeEditModules/Settings
//
//  Created by Nanashi Li on 2022/04/08.
//

import AppKit
import Foundation

extension SettingsData {

    /// The global settings for the terminal emulator
    struct TerminalSettings: Codable, Hashable, SearchableSettingsPage {

        /// The search keys
        var searchKeys: [String] {
            [
                "Shell",
                "Use \"Option\" key as \"Meta\"",
                "Use text editor font",
                "Font",
                "Font Size",
                "Terminal Cursor Style",
                "Blink Cursor"
            ]
            .map { NSLocalizedString($0, comment: "") }
        }

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

        // Use font settings from Text Editing
        var useTextEditorFont: Bool = true

        /// If `true`, use injection scripts for terminal features like automatic tab title.
        var useShellIntegration: Bool = true

        /// If `true`, use a login shell.
        var useLoginShell: Bool = true

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
            self.useTextEditorFont = try container.decodeIfPresent(Bool.self, forKey: .useTextEditorFont) ?? true
            self.useShellIntegration = try container.decodeIfPresent(Bool.self, forKey: .useShellIntegration) ?? true
            self.useLoginShell = try container.decodeIfPresent(Bool.self, forKey: .useLoginShell) ?? true
        }
    }

    /// The shell options.
    /// - **bash**: uses the default bash shell
    /// - **zsh**: uses the ZSH shell
    /// - **system**: uses the system default shell (most likely ZSH)
    enum TerminalShell: String, Codable, Hashable {
        case bash
        case zsh
        case system
    }

    enum TerminalCursorStyle: String, Codable, Hashable {
        case block
        case underline
        case bar
    }

    struct TerminalFont: Codable, Hashable {
        /// The font size for the custom font
        var size: Double = 12

        /// The name of the custom font
        var name: String = "SF Mono"

        /// Default initializer
        init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.size = try container.decodeIfPresent(Double.self, forKey: .size) ?? size
            self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? name
        }

        /// Returns an NSFont representation of the current configuration.
        ///
        /// Returns the custom font, if enabled and able to be instantiated.
        /// Otherwise returns a default system font monospaced.
        var current: NSFont {
            return NSFont(name: name, size: size) ?? NSFont.monospacedSystemFont(ofSize: size, weight: .medium)
        }
    }
}
