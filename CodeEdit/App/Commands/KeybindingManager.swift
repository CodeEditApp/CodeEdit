//
//  KeybindingManager.swift
//
//  Created by Alex on 09.05.2022.
//

import Foundation
import SwiftUI
import CodeEditSettings

final class KeybindingManager: KeybindingManaging {
    /// Array which contains all available keyboard shortcuts
    var keyboardShortcuts = [String: KeyboardShortcutWrapper]()

    init() {
        loadKeybindings()
    }

    // We need this fallback shortcut because optional shortcuts available only from 12.3, while we have target of 12.0x
    var fallbackShortcut = KeyboardShortcutWrapper(
        name: "?",
        description: "Test",
        context: "Fallback",
        keybinding: "?",
        modifier: "shift",
        id: "fallback"
    )

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
