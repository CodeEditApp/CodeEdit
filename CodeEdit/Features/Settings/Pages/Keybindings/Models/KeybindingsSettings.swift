//
//  KeybindingsPreferences.swift
//  CodeEditModules/Settings
//  
//  Created by Alex on 18.05.2022.
//

import Foundation

extension SettingsData {

    /// The global settings for text editing
    struct KeybindingsSettings: Codable, Hashable {

        /// An integer indicating how many spaces a `tab` will generate
        var keybindings: [String: KeyboardShortcutWrapper] = .init()

        /// Default initializer
        init() {
            self.keybindings = KeybindingManager.shared.keyboardShortcuts
        }

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.keybindings = try container.decodeIfPresent(
                [String: KeyboardShortcutWrapper].self,
                forKey: .keybindings
            ) ?? .init()
            appendNew()
        }

        /// Adds new keybindings if they were added to default_keybindings.json.
        /// To ensure users will get new keybindings with new app version releases
        private mutating func appendNew() {
            let newKeybindings = KeybindingManager.shared
                .keyboardShortcuts.filter { !keybindings.keys.contains($0.key) }
            for keybinding in newKeybindings {
                self.keybindings[keybinding.key] = KeybindingManager.shared.named(with: keybinding.key)
            }
        }
    }
}
