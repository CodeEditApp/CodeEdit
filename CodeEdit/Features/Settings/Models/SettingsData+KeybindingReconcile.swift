//
//  SettingsData+KeybindingReconcile.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom.
//

import Foundation
import Factory

extension SettingsData {
    /// Merges bundled-default keybindings (from `default_keybindings.json`, owned by
    /// `KeybindingManager`) into the persisted settings, adding only keys the user does
    /// not already have. Preserves user overrides. Invoked once at app startup —
    /// previously ran as a side effect of decoding `KeybindingsSettings`.
    static func reconcileDefaultKeybindings() {
        let defaults = Container.shared.keybindingManager().keyboardShortcuts
        var current = Settings.shared.preferences.keybindings.keybindings
        for (key, _) in defaults where current[key] == nil {
            current[key] = Container.shared.keybindingManager().named(with: key)
        }
        Settings.shared.preferences.keybindings.keybindings = current
    }
}
