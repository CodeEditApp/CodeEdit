//
//  TerminalPreferences.swift
//  CodeEditModules/AppPreferences
//
//  Created by Nanashi Li on 2022/04/08.
//

import Foundation

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
        public var name: String = "SFMono-Medium"

        /// Default initializer
        public init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.customFont = try container.decodeIfPresent(Bool.self, forKey: .customFont) ?? false
            self.size = try container.decodeIfPresent(Int.self, forKey: .size) ?? 11
            self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "SFMono-Medium"
        }
    }
}
