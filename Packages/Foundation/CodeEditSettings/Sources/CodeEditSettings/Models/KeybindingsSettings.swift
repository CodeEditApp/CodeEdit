//
//  KeybindingsPreferences.swift
//  CodeEditModules/Settings
//  
//  Created by Alex on 18.05.2022.
//

import Foundation

extension SettingsData {

    /// The global settings for text editing
    public struct KeybindingsSettings: Codable, Hashable {

        /// An integer indicating how many spaces a `tab` will generate
        public var keybindings: [String: KeyboardShortcutWrapper] = .init()

        /// Default initializer — empty; bundled defaults are seeded by the app at
        /// startup via `SettingsData.reconcileDefaultKeybindings()`.
        public init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.keybindings = try container.decodeIfPresent(
                [String: KeyboardShortcutWrapper].self,
                forKey: .keybindings
            ) ?? .init()
        }
    }
}
