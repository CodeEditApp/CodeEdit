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
    public struct TerminalSettings: Codable, Hashable {

        /// If true terminal will use editor theme.
        @CodableDefault<DefaultTrue> public var useEditorTheme = true

        /// If true terminal appearance will always be `dark`. Otherwise it adapts to the system setting.
        @CodableDefault<DefaultFalse> public var darkAppearance = false

        /// If true, the terminal uses the background color of the theme, otherwise it is clear
        @CodableDefault<DefaultTrue> public var useThemeBackground = true

        /// If true, the terminal treats the `Option` key as the `Meta` key
        @CodableDefault<DefaultFalse> public var optionAsMeta = false

        /// The selected shell to use.
        @CodableDefault<DefaultTerminalShell> public var shell: TerminalShell = .system

        /// The font to use in terminal.
        @CodableDefault<DefaultTerminalFont> public var font: TerminalFont = .init()

        // The cursor style to use in terminal
        @CodableDefault<DefaultTerminalCursorStyle> public var cursorStyle: TerminalCursorStyle = .block

        // Toggle for blinking cursor or not
        @CodableDefault<DefaultFalse> public var cursorBlink = false

        // Use font settings from Text Editing
        @CodableDefault<DefaultTrue> public var useTextEditorFont = true

        /// If `true`, use injection scripts for terminal features like automatic tab title.
        @CodableDefault<DefaultTrue> public var useShellIntegration = true

        /// If `true`, use a login shell.
        @CodableDefault<DefaultTrue> public var useLoginShell = true

        /// Default initializer
        public init() {}
    }

    /// The shell options.
    /// - **bash**: uses the default bash shell
    /// - **zsh**: uses the ZSH shell
    /// - **system**: uses the system default shell (most likely ZSH)
    public enum TerminalShell: String, Codable, Hashable {
        case bash
        case zsh
        case system
    }

    public enum TerminalCursorStyle: String, Codable, Hashable {
        case block
        case underline
        case bar
    }

    public struct TerminalFont: Codable, Hashable {
        /// The font size for the custom font
        public var size: Double = 12

        /// The name of the custom font
        public var name: String = "SF Mono"

        /// The weight of the custom font
        public var weight: NSFont.Weight = .medium

        /// Default initializer
        public init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.size = try container.decodeIfPresent(Double.self, forKey: .size) ?? size
            self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? name
            self.weight = try container.decodeIfPresent(NSFont.Weight.self, forKey: .weight) ?? weight
        }

        /// Returns an NSFont representation of the current configuration.
        ///
        /// Returns the custom font, if enabled and able to be instantiated.
        /// Otherwise returns a default system font monospaced.
        public var current: NSFont {
            let customFont = NSFont(name: name, size: size)?.withWeight(weight: weight)
            return customFont ?? NSFont.monospacedSystemFont(ofSize: size, weight: .medium)
        }
    }
}
