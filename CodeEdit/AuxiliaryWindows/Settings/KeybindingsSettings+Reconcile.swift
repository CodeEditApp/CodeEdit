//
//  KeybindingsSettings+Reconcile.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom.
//

import Foundation
import CodeEditSettings
import CodeEditCore

extension KeybindingsSettings {
    /// Merges bundled-default keybindings (from `default_keybindings.json`, owned by
    /// `KeybindingManager`) into the persisted settings, adding only keys the user does
    /// not already have. Preserves user overrides. Invoked once at app startup —
    /// previously ran as a side effect of decoding `KeybindingsSettings`.
    static func reconcileDefaults(keybindingManager: KeybindingManaging, settings: SettingsAccessing) {
        let defaults = keybindingManager.keyboardShortcuts
        var section = settings.value(KeybindingsSettings.self)
        for (key, _) in defaults where section.keybindings[key] == nil {
            section.keybindings[key] = keybindingManager.named(with: key)
        }
        settings.setValue(section)
    }
}
