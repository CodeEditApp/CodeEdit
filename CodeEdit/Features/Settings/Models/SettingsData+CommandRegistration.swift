//
//  SettingsData+CommandRegistration.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom.
//

import Foundation
import CodeEditSettings
import Factory

extension SettingsData.TextEditingSettings {
    /// Registers toggle-able text-editing preferences with the command palette.
    /// Invoked once at app startup (previously ran as a side effect of decoding).
    static func registerCommands() {
        let mgr = Container.shared.commandManager()

        mgr.addCommand(
            name: "Toggle Type-Over Completion",
            title: "Toggle Type-Over Completion",
            id: "prefs.text_editing.type_over_completion"
        ) {
            Settings[\.textEditing].enableTypeOverCompletion.toggle()
        }
        mgr.addCommand(
            name: "Toggle Autocomplete Braces",
            title: "Toggle Autocomplete Braces",
            id: "prefs.text_editing.autocomplete_braces"
        ) {
            Settings[\.textEditing].autocompleteBraces.toggle()
        }
        mgr.addCommand(
            name: "Toggle Word Wrap",
            title: "Toggle Word Wrap",
            id: "prefs.text_editing.wrap_lines_to_editor_width"
        ) {
            Settings[\.textEditing].wrapLinesToEditorWidth.toggle()
        }
        mgr.addCommand(name: "Toggle Minimap", title: "Toggle Minimap", id: "prefs.text_editing.toggle_minimap") {
            Settings[\.textEditing].showMinimap.toggle()
        }
        mgr.addCommand(name: "Toggle Gutter", title: "Toggle Gutter", id: "prefs.text_editing.toggle_gutter") {
            Settings[\.textEditing].showGutter.toggle()
        }
        mgr.addCommand(
            name: "Toggle Folding Ribbon",
            title: "Toggle Folding Ribbon",
            id: "prefs.text_editing.toggle_folding_ribbon"
        ) {
            Settings[\.textEditing].showFoldingRibbon.toggle()
        }
    }
}
