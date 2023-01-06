//
//  TextEditingPreferences.swift
//  CodeEditModules/AppPreferences
//
//  Created by Nanashi Li on 2022/04/08.
//

import Foundation

extension AppPreferences {

    /// The global settings for text editing
    struct TextEditingPreferences: Codable {
        /// An integer indicating how many spaces a `tab` will generate
        var defaultTabWidth: Int = 4

        /// The font to use in editor.
        var font: EditorFont = .init()

        var enableTypeOverCompletion: Bool = true

        var autocompleteBraces: Bool = true

        var wrapLinesToEditorWidth: Bool = true

        /// Default initializer
        init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.defaultTabWidth = try container.decodeIfPresent(Int.self, forKey: .defaultTabWidth) ?? 4
            self.font = try container.decodeIfPresent(EditorFont.self, forKey: .font) ?? .init()
            self.enableTypeOverCompletion = try container.decodeIfPresent(
                Bool.self, forKey: .enableTypeOverCompletion) ?? true
            self.autocompleteBraces = try container.decodeIfPresent(Bool.self,
                                                                    forKey: .autocompleteBraces) ?? true
            self.wrapLinesToEditorWidth = try container.decodeIfPresent(Bool.self,
                                                                    forKey: .wrapLinesToEditorWidth) ?? true
            self.populateCommands()
        }

        /// Adds toggle-able preferences to the command palette via shared `CommandManager`
        private func populateCommands() {
            let mgr = CommandManager.shared

            mgr.addCommand(
                name: "Toggle Type-Over Completion",
                title: "Toggle Type-Over Completion",
                id: "prefs.text_editing.type_over_completion",
                command: CommandClosureWrapper {
                    AppPreferencesModel.shared.preferences.textEditing.enableTypeOverCompletion.toggle()
            })

            mgr.addCommand(
                name: "Toggle Autocomplete Braces",
                title: "Toggle Autocomplete Braces",
                id: "prefs.text_editing.autocomplete_braces",
                command: CommandClosureWrapper {
                    AppPreferencesModel.shared.preferences.textEditing.autocompleteBraces.toggle()
            })

            mgr.addCommand(
                name: "Toggle Word Wrap",
                title: "Toggle Word Wrap",
                id: "prefs.text_editing.wrap_lines_to_editor_width",
                command: CommandClosureWrapper {
                    AppPreferencesModel.shared.preferences.textEditing.wrapLinesToEditorWidth.toggle()
            })
        }
    }

    struct EditorFont: Codable, Equatable {
        /// Indicates whether or not to use a custom font
        var customFont: Bool = false

        /// The font size for the custom font
        var size: Int = 11

        /// The name of the custom font
        var name: String = "SFMono-Medium"

        /// Default initializer
        init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.customFont = try container.decodeIfPresent(Bool.self, forKey: .customFont) ?? false
            self.size = try container.decodeIfPresent(Int.self, forKey: .size) ?? 11
            self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "SFMono-Medium"
        }
    }
}
