//
//  TextEditingPreferences.swift
//  CodeEditModules/Settings
//
//  Created by Nanashi Li on 2022/04/08.
//

import AppKit
import Foundation

extension SettingsData {

    /// The global settings for text editing
    struct TextEditingSettings: Codable, Hashable, SearchableSettingsPage {

        var searchKeys: [String] {
            [
                "Prefer Indent Using",
                "Tab Width",
                "Wrap lines to editor width",
                "Font",
                "Font Size",
                "Line Height",
                "Letter Spacing",
                "Autocomplete braces",
                "Enable type-over completion",
                "Bracket Pair Highlight"
            ]
            .map { NSLocalizedString($0, comment: "") }
        }

        /// An integer indicating how many spaces a `tab` will appear as visually.
        var defaultTabWidth: Int = 4

        /// The behavior of a `tab` keypress. If `.tab`, will insert a tab character. If `.spaces` will insert
        /// `.spaceCount` spaces instead.
        var indentOption: IndentOption = IndentOption(indentType: .spaces, spaceCount: 4)

        /// The font to use in editor.
        var font: EditorFont = .init()

        /// A flag indicating whether type-over completion is enabled
        var enableTypeOverCompletion: Bool = true

        /// A flag indicating whether braces are automatically completed
        var autocompleteBraces: Bool = true

        /// A flag indicating whether to wrap lines to editor width
        var wrapLinesToEditorWidth: Bool = true

        /// A multiplier for setting the line height. Defaults to `1.45`
        var lineHeightMultiple: Double = 1.45

        /// A multiplier for setting the letter spacing, `1` being no spacing and
        /// `2` is one character of spacing between letters, defaults to `1`.
        var letterSpacing: Double = 1.0

        /// The behavior of bracket pair highlights.
        var bracketHighlight: BracketPairHighlight = BracketPairHighlight()

        /// Default initializer
        init() {
            self.populateCommands()
        }

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.defaultTabWidth = try container.decodeIfPresent(Int.self, forKey: .defaultTabWidth) ?? 4
            self.indentOption = try container.decodeIfPresent(
                IndentOption.self,
                forKey: .indentOption
            ) ?? IndentOption(indentType: .spaces, spaceCount: 4)
            self.font = try container.decodeIfPresent(EditorFont.self, forKey: .font) ?? .init()
            self.enableTypeOverCompletion = try container.decodeIfPresent(
                Bool.self,
                forKey: .enableTypeOverCompletion
            ) ?? true
            self.autocompleteBraces = try container.decodeIfPresent(
                Bool.self,
                forKey: .autocompleteBraces
            ) ?? true
            self.wrapLinesToEditorWidth = try container.decodeIfPresent(
                Bool.self,
                forKey: .wrapLinesToEditorWidth
            ) ?? true
            self.lineHeightMultiple = try container.decodeIfPresent(
                Double.self,
                forKey: .lineHeightMultiple
            ) ?? 1.45
            self.letterSpacing = try container.decodeIfPresent(
                Double.self,
                forKey: .letterSpacing
            ) ?? 1
            self.bracketHighlight = try container.decodeIfPresent(
                BracketPairHighlight.self,
                forKey: .bracketHighlight
            ) ?? BracketPairHighlight()

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
                    Settings.shared.preferences.textEditing.enableTypeOverCompletion.toggle()
                }
            )

            mgr.addCommand(
                name: "Toggle Autocomplete Braces",
                title: "Toggle Autocomplete Braces",
                id: "prefs.text_editing.autocomplete_braces",
                command: CommandClosureWrapper {
                    Settings.shared.preferences.textEditing.autocompleteBraces.toggle()
                }
            )

            mgr.addCommand(
                name: "Toggle Word Wrap",
                title: "Toggle Word Wrap",
                id: "prefs.text_editing.wrap_lines_to_editor_width",
                command: CommandClosureWrapper {
                    Settings[\.textEditing].wrapLinesToEditorWidth.toggle()
                }
            )
        }

        struct IndentOption: Codable, Hashable {
            var indentType: IndentType
            // Kept even when `indentType` is `.tab` to retain the user's
            // settings when changing `indentType`.
            var spaceCount: Int = 4

            enum IndentType: String, Codable {
                case tab
                case spaces
            }
        }

        struct BracketPairHighlight: Codable, Hashable {
            /// The type of highlight to use
            var highlightType: HighlightType = .flash
            var useCustomColor: Bool = false
            /// The color to use for the highlight.
            var color: Theme.Attributes = Theme.Attributes(color: "FFFFFF")

            enum HighlightType: String, Codable {
                case disabled
                case bordered
                case flash
                case underline
            }
        }
    }

    struct EditorFont: Codable, Hashable {
        /// The font size for the font
        var size: Double = 12

        /// The name of the custom font
        var name: String = "SF Mono"

        /// Default initializer
        init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.size = try container.decodeIfPresent(Double.self, forKey: .size) ?? size
            self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? name
        }

        /// Returns an NSFont representation of the current configuration.
        ///
        /// Returns the custom font, if enabled and able to be instantiated.
        /// Otherwise returns a default system font monospaced.
        var current: NSFont {
            return NSFont(name: name, size: size) ?? NSFont.monospacedSystemFont(ofSize: size, weight: .medium)
        }
    }
}
