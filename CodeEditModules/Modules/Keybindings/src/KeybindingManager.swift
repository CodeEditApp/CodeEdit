//
//  KeybindingManager.swift
//  
//
//  Created by Alex on 09.05.2022.
//

import Foundation
import SwiftUI
import AppPreferences

public final class KeybindingManager {
    init() {
        self.keyboardShortcuts = ["recentProjectsViewCopyPath":
                                    KeyboardShortcutWrapper(name: "Copy Path", description: "test",
                                                            context: "recentProjects",
                                                            keybinding: "C",
                                                            modifiers: [".command"])]
        loadKeybindings()
    }

    static public var shared = KeybindingManager()

    // We need this fallback shortcut because optional shortcuts available only from 12.3, while we have target of 12.0x
    var fallbackShortcut = KeyboardShortcutWrapper(name: "?", description: "Test", context: "Fallback",
                                                   keybinding: "?", modifiers: [".command", ".shift"])

    public var keyboardShortcuts: [String: KeyboardShortcutWrapper]

    public func addNewShortcut(shortcut: KeyboardShortcutWrapper, name: String) {
        KeybindingManager.shared.keyboardShortcuts[name] = (shortcut)
    }

    private func loadKeybindings() {

        var bindingsURL = Bundle.module.url(forResource: "default_keybindings.json", withExtension: nil)
        guard var json = try? Data(contentsOf: bindingsURL!),
              var prefs = try? JSONDecoder().decode(AppPreferences.self, from: json) else {
            return
        }

        print(json)
//        let preferenceURL = AppPreferencesModel.shared.preferencesURL
    }

    private func loadDefaultKeybindings() {

    }

    public func named(with name: String) -> KeyboardShortcutWrapper {
        let foundElement = keyboardShortcuts[name]
        return foundElement != nil ? foundElement! : fallbackShortcut
    }

}

public struct KeyboardShortcutWrapper: Codable {
    public var keyboardShortcut: KeyboardShortcut {
        KeyboardShortcut.init(.init(Character(keybinding)))
    }
    var name: String
    var description: String
    var context: String
    var keybinding: String
    var modifiers: [String]

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case context
        case keybinding
        case modifiers
    }

    init(name: String, description: String, context: String, keybinding: String, modifiers: [String]) {
        self.name = name
        self.description = description
        self.context = context
        self.keybinding = keybinding
        self.modifiers = modifiers
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        context = try container.decode(String.self, forKey: .context)
        keybinding = try container.decode(String.self, forKey: .keybinding)
        modifiers = try container.decode([String].self, forKey: .modifiers)
    }

    func encode(from encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
    }

}
