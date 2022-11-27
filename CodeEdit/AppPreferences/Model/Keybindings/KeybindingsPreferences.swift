//
//  KeybindingsPreferences.swift
//  CodeEditModules/AppPreferences
//  
//  Created by Alex on 18.05.2022.
//

import Foundation

extension AppPreferences {

    /// The global settings for text editing
    struct KeybindingsPreferences: Codable {
        /// An integer indicating how many spaces a `tab` will generate
        var keybindings: [String: KeyboardShortcutWrapper] = .init()

        /// Default initializer
        init() {
            self.keybindings = KeybindingManager.shared.keyboardShortcuts
        }

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.keybindings = try container.decodeIfPresent([String: KeyboardShortcutWrapper].self,
                                                                       forKey: .keybindings) ?? .init()
            appendNew()

            let mgr = CommandManager.shared
            let wrap = ClosureWrapper.init(closure: {
                print("testing closure")
            })
            mgr.addCommand(name: "Send test to console",
                           title: "Send test to console", id: "codeedit.test", command: wrap)
            mgr.executeCommand(name: "test")
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
