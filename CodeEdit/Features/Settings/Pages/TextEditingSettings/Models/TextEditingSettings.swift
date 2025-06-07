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
            var keys = [
                "Prefer Indent Using",
                "Tab Width",
                "Wrap lines to editor width",
                "Editor Overscroll",
                "Font",
                "Font Size",
                "Font Weight",
                "Line Height",
                "Letter Spacing",
                "Autocomplete braces",
                "Enable type-over completion",
                "Bracket Pair Emphasis",
                "Bracket Pair Highlight",
                "Show Minimap",
                "Reformat at Column",
                "Show Reformatting Guide",
            ]
            if #available(macOS 14.0, *) {
                keys.append("System Cursor")
            }
            return keys.map { NSLocalizedString($0, comment: "") }
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

        /// The percentage of overscroll to apply to the text view
        var overscroll: OverscrollOption = .medium

        /// A multiplier for setting the line height. Defaults to `1.2`
        var lineHeightMultiple: Double = 1.2

        /// A multiplier for setting the letter spacing, `1` being no spacing and
        /// `2` is one character of spacing between letters, defaults to `1`.
        var letterSpacing: Double = 1.0

        /// The behavior of bracket pair highlights.
        var bracketEmphasis: BracketPairEmphasis = BracketPairEmphasis()

        /// Use the system cursor for the source editor.
        var useSystemCursor: Bool = true

        /// Toggle the minimap in the editor.
        var showMinimap: Bool = true

        /// The column at which to reformat text
        var reformatAtColumn: Int = 80

        /// Show the reformatting guide in the editor
        var showReformattingGuide: Bool = false

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
            self.overscroll = try container.decodeIfPresent(
                OverscrollOption.self,
                forKey: .overscroll
            ) ?? .medium
            self.lineHeightMultiple = try container.decodeIfPresent(
                Double.self,
                forKey: .lineHeightMultiple
            ) ?? 1.2
            self.letterSpacing = try container.decodeIfPresent(
                Double.self,
                forKey: .letterSpacing
            ) ?? 1
            self.bracketEmphasis = try container.decodeIfPresent(
                BracketPairEmphasis.self,
                forKey: .bracketEmphasis
            ) ?? BracketPairEmphasis()
            if #available(macOS 14, *) {
                self.useSystemCursor = try container.decodeIfPresent(Bool.self, forKey: .useSystemCursor) ?? true
            } else {
                self.useSystemCursor = false
            }

            self.showMinimap = try container.decodeIfPresent(Bool.self, forKey: .showMinimap) ?? true
            self.reformatAtColumn = try container.decodeIfPresent(Int.self, forKey: .reformatAtColumn) ?? 80
            self.showReformattingGuide = try container.decodeIfPresent(
                Bool.self,
                forKey: .showReformattingGuide
            ) ?? false

            self.populateCommands()
        }

        /// Adds toggle-able preferences to the command palette via shared `CommandManager`
        private func populateCommands() {
            let mgr = CommandManager.shared

            mgr.addCommand(
                name: "Toggle Type-Over Completion",
                title: "Toggle Type-Over Completion",
                id: "prefs.text_editing.type_over_completion",
                command: {
                    Settings[\.textEditing].enableTypeOverCompletion.toggle()
                }
            )

            mgr.addCommand(
                name: "Toggle Autocomplete Braces",
                title: "Toggle Autocomplete Braces",
                id: "prefs.text_editing.autocomplete_braces",
                command: {
                    Settings[\.textEditing].autocompleteBraces.toggle()
                }
            )

            mgr.addCommand(
                name: "Toggle Word Wrap",
                title: "Toggle Word Wrap",
                id: "prefs.text_editing.wrap_lines_to_editor_width",
                command: {
                    Settings[\.textEditing].wrapLinesToEditorWidth.toggle()
                }
            )

            mgr.addCommand(
                name: "Toggle Minimap",
                title: "Toggle Minimap",
                id: "prefs.text_editing.toggle_minimap"
            ) {
                Settings[\.textEditing].showMinimap.toggle()
            }
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

        struct BracketPairEmphasis: Codable, Hashable {
            /// The type of highlight to use
            var highlightType: HighlightType = .flash
            var useCustomColor: Bool = false
            /// The color to use for the highlight.
            var color: Theme.Attributes = Theme.Attributes(color: "FFFFFF", bold: false, italic: false)

            enum HighlightType: String, Codable {
                case disabled
                case bordered
                case flash
                case underline
            }
        }

        enum OverscrollOption: String, Codable {
            case none
            case small
            case medium
            case large

            var overscrollPercentage: CGFloat {
                switch self {
                case .none: return 0
                case .small: return 0.25
                case .medium: return 0.5
                case .large: return 0.75
                }
            }
        }
    }

    struct EditorFont: Codable, Hashable {
        /// The font size for the font
        var size: Double = 12

        /// The name of the custom font
        var name: String = "SF Mono"

        /// The weight of the custom font
        var weight: NSFont.Weight = .medium

        /// Default initializer
        init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.size = try container.decodeIfPresent(Double.self, forKey: .size) ?? size
            self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? name
            self.weight = try container.decodeIfPresent(NSFont.Weight.self, forKey: .weight) ?? weight
        }

        /// Returns an NSFont representation of the current configuration.
        ///
        /// Returns the custom font, if enabled and able to be instantiated.
        /// Otherwise returns a default system font monospaced.
        var current: NSFont {
            let customFont = NSFont(name: name, size: size)?.withWeight(weight: weight)
            return customFont ?? NSFont.monospacedSystemFont(ofSize: size, weight: .medium)
        }
    }
}
