//
//  KeybindingManager.swift
//  
//
//  Created by Alex on 09.05.2022.
//

import Foundation
import SwiftUI

final class KeybindingManager {
    /// Array which contains all available keyboard shortcuts
    var keyboardShortcuts = [String: KeyboardShortcutWrapper]()

    private init() {
        loadKeybindings()
    }

    /// Static method to access singleton
    static let shared: KeybindingManager = .init()

    // We need this fallback shortcut because optional shortcuts available only from 12.3, while we have target of 12.0x
    var fallbackShortcut = KeyboardShortcutWrapper(name: "?", description: "Test", context: "Fallback",
                                                   keybinding: "?", modifier: "shift", id: "fallback")

    /// Adds new shortcut
    func addNewShortcut(shortcut: KeyboardShortcutWrapper, name: String) {
        keyboardShortcuts[name] = shortcut
    }

    private func loadKeybindings() {

        let bindingsURL = Bundle.main.url(forResource: "default_keybindings.json", withExtension: nil)
        if let json = try? Data(contentsOf: bindingsURL!) {
            do {
                let prefs = try JSONDecoder().decode([KeyboardShortcutWrapper].self, from: json)
                for pref in prefs {
                    addNewShortcut(shortcut: pref, name: pref.id)
                }
                } catch {
                    print("error:\(error)")
                }
        }
        return
    }

    /// Get shortcut by name
    /// - Parameter name: shortcut name
    /// - Returns: KeyboardShortcutWrapper
    func named(with name: String) -> KeyboardShortcutWrapper {
        let foundElement = keyboardShortcuts[name]
        return foundElement != nil ? foundElement! : fallbackShortcut
    }

}

/// Wrapper for KeyboardShortcut. It contains name, keybindings.
struct KeyboardShortcutWrapper: Codable {
    var keyboardShortcut: KeyboardShortcut {
        return KeyboardShortcut.init(.init(Character(keybinding)), modifiers: parsedModifier)
    }

    var parsedModifier: EventModifiers {
        switch modifier {
        case "command":
            return EventModifiers.command
        case "shift":
            return EventModifiers.shift
        case "option":
            return EventModifiers.option
        case "control":
            return EventModifiers.control
        default:
            return EventModifiers.command
        }
    }
    var name: String
    var description: String
    var context: String
    var keybinding: String
    var modifier: String
    var id: String

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case context
        case keybinding
        case modifier
        case id
    }

    init(name: String, description: String, context: String, keybinding: String, modifier: String, id: String) {
        self.name = name
        self.description = description
        self.context = context
        self.keybinding = keybinding
        self.modifier = modifier
        self.id = id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        context = try container.decode(String.self, forKey: .context)
        keybinding = try container.decode(String.self, forKey: .keybinding)
        modifier = try container.decode(String.self, forKey: .modifier)
        id = try container.decode(String.self, forKey: .id)
    }
}
