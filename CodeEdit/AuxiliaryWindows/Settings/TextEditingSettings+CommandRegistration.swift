//
//  TextEditingSettings+CommandRegistration.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom.
//

import Foundation
import CodeEditCore
import CodeEditSettings

extension TextEditingSettings {
    /// Registers toggle-able text-editing preferences with the command palette.
    /// Invoked once at app startup (previously ran as a side effect of decoding).
    ///
    /// `settings` is captured by the command closures, which outlive this call — the composition
    /// root owns the store, so the capture is of the one live store, not a copy of its values.
    static func registerCommands(in mgr: CommandManaging, settings: SettingsAccessing) {
        func toggle(_ keyPath: WritableKeyPath<TextEditingSettings, Bool>) {
            var section = settings.value(TextEditingSettings.self)
            section[keyPath: keyPath].toggle()
            settings.setValue(section)
        }

        mgr.addCommand(
            name: "Toggle Type-Over Completion",
            title: "Toggle Type-Over Completion",
            id: "prefs.text_editing.type_over_completion"
        ) {
            toggle(\.enableTypeOverCompletion)
        }
        mgr.addCommand(
            name: "Toggle Autocomplete Braces",
            title: "Toggle Autocomplete Braces",
            id: "prefs.text_editing.autocomplete_braces"
        ) {
            toggle(\.autocompleteBraces)
        }
        mgr.addCommand(
            name: "Toggle Word Wrap",
            title: "Toggle Word Wrap",
            id: "prefs.text_editing.wrap_lines_to_editor_width"
        ) {
            toggle(\.wrapLinesToEditorWidth)
        }
        mgr.addCommand(name: "Toggle Minimap", title: "Toggle Minimap", id: "prefs.text_editing.toggle_minimap") {
            toggle(\.showMinimap)
        }
        mgr.addCommand(name: "Toggle Gutter", title: "Toggle Gutter", id: "prefs.text_editing.toggle_gutter") {
            toggle(\.showGutter)
        }
        mgr.addCommand(
            name: "Toggle Folding Ribbon",
            title: "Toggle Folding Ribbon",
            id: "prefs.text_editing.toggle_folding_ribbon"
        ) {
            toggle(\.showFoldingRibbon)
        }
    }
}
