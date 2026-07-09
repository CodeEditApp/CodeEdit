//
//  TextEditingPreferences.swift
//  CodeEditModules/Settings
//
//  Created by Nanashi Li on 2022/04/08.
//

import AppKit
import CodeEditCore
import Foundation

extension SettingsData {

    /// The global settings for text editing
    public struct TextEditingSettings: Codable, Hashable {

        /// An integer indicating how many spaces a `tab` will appear as visually.
        public var defaultTabWidth: Int = 4

        /// The behavior of a `tab` keypress. If `.tab`, will insert a tab character. If `.spaces` will insert
        /// `.spaceCount` spaces instead.
        public var indentOption: IndentOption = IndentOption(indentType: .spaces, spaceCount: 4)

        /// The font to use in editor.
        public var font: EditorFont = .init()

        /// A flag indicating whether type-over completion is enabled
        public var enableTypeOverCompletion: Bool = true

        /// A flag indicating whether braces are automatically completed
        public var autocompleteBraces: Bool = true

        /// A flag indicating whether to wrap lines to editor width
        public var wrapLinesToEditorWidth: Bool = true

        /// The percentage of overscroll to apply to the text view
        public var overscroll: OverscrollOption = .medium

        /// A multiplier for setting the line height. Defaults to `1.2`
        public var lineHeightMultiple: Double = 1.2

        /// A multiplier for setting the letter spacing, `1` being no spacing and
        /// `2` is one character of spacing between letters, defaults to `1`.
        public var letterSpacing: Double = 1.0

        /// The behavior of bracket pair highlights.
        public var bracketEmphasis: BracketPairEmphasis = BracketPairEmphasis()

        /// Use the system cursor for the source editor.
        public var useSystemCursor: Bool = true

        /// Toggle the gutter in the editor.
        public var showGutter: Bool = true

        /// Toggle the minimap in the editor.
        public var showMinimap: Bool = true

        /// Toggle the code folding ribbon.
        public var showFoldingRibbon: Bool = true

        /// The column at which to reformat text
        public var reformatAtColumn: Int = 80

        /// Show the reformatting guide in the editor
        public var showReformattingGuide: Bool = false

        public var invisibleCharacters: InvisibleCharactersConfig = .default

        /// Map of unicode character codes to a note about them
        public var warningCharacters: WarningCharacters = .default

        /// Default initializer
        public init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws { // swiftlint:disable:this function_body_length
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

            self.showGutter = try container.decodeIfPresent(Bool.self, forKey: .showGutter) ?? true
            self.showMinimap = try container.decodeIfPresent(Bool.self, forKey: .showMinimap) ?? true
            self.showFoldingRibbon = try container.decodeIfPresent(Bool.self, forKey: .showFoldingRibbon) ?? true
            self.reformatAtColumn = try container.decodeIfPresent(Int.self, forKey: .reformatAtColumn) ?? 80
            self.showReformattingGuide = try container.decodeIfPresent(
                Bool.self,
                forKey: .showReformattingGuide
            ) ?? false
            self.invisibleCharacters = try container.decodeIfPresent(
                InvisibleCharactersConfig.self,
                forKey: .invisibleCharacters
            ) ?? .default
            self.warningCharacters = try container.decodeIfPresent(
                WarningCharacters.self,
                forKey: .warningCharacters
            ) ?? .default
        }

        /// Re-exported from `CodeEditCore`. Keeps `SettingsData.TextEditingSettings.IndentOption`
        /// valid for all existing call sites while the underlying type lives in the Core package.
        public typealias IndentOption = CodeEditCore.IndentOption

        public struct BracketPairEmphasis: Codable, Hashable {
            /// The type of highlight to use
            public var highlightType: HighlightType = .flash
            public var useCustomColor: Bool = false
            /// The color to use for the highlight.
            public var color: Theme.Attributes = Theme.Attributes(color: "FFFFFF", bold: false, italic: false)

            public enum HighlightType: String, Codable {
                case disabled
                case bordered
                case flash
                case underline
            }
        }

        public enum OverscrollOption: String, Codable {
            case none
            case small
            case medium
            case large

            public var overscrollPercentage: CGFloat {
                switch self {
                case .none: return 0
                case .small: return 0.25
                case .medium: return 0.5
                case .large: return 0.75
                }
            }
        }

        public struct InvisibleCharactersConfig: Equatable, Hashable, Codable {
            nonisolated(unsafe) public static var `default`: InvisibleCharactersConfig  = {
                InvisibleCharactersConfig(
                    enabled: false,
                    showSpaces: true,
                    showTabs: true,
                    showLineEndings: true
                )
            }()

            public var enabled: Bool

            public var showSpaces: Bool
            public var showTabs: Bool
            public var showLineEndings: Bool

            public var spaceReplacement: String = "·"
            public var tabReplacement: String = "→"

            // Controlled by `showLineEndings`
            public var carriageReturnReplacement: String = "↵"
            public var lineFeedReplacement: String = "¬"
            public var paragraphSeparatorReplacement: String = "¶"
            public var lineSeparatorReplacement: String = "⏎"
        }

        public struct WarningCharacters: Equatable, Hashable, Codable {
            nonisolated(unsafe) public static let `default`: WarningCharacters  = WarningCharacters(enabled: true, characters: [
                0x0003: "End of text",

                0x00A0: "Non-breaking space",
                0x202F: "Narrow non-breaking space",
                0x200B: "Zero-width space",
                0x200C: "Zero-width non-joiner",
                0x2029: "Paragraph separator",

                0x2013: "Em-dash",
                0x00AD: "Soft hyphen",

                0x2018: "Left single quote",
                0x2019: "Right single quote",
                0x201C: "Left double quote",
                0x201D: "Right double quote",

                0x037E: "Greek Question Mark"
            ])

            public var enabled: Bool
            public var characters: [UInt16: String]
        }
    }

    public struct EditorFont: Codable, Hashable {
        /// The font size for the font
        public var size: Double = 12

        /// The name of the custom font
        public var name: String = "SF Mono"

        /// The weight of the custom font
        public var weight: NSFont.Weight = .medium

        /// Default initializer
        public init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.size = try container.decodeIfPresent(Double.self, forKey: .size) ?? size
            self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? name
            self.weight = try container.decodeIfPresent(NSFont.Weight.self, forKey: .weight) ?? weight
        }

        /// Returns an NSFont representation of the current configuration.
        ///
        /// Returns the custom font, if enabled and able to be instantiated.
        /// Otherwise returns a default system font monospaced.
        public var current: NSFont {
            let customFont = NSFont(name: name, size: size)?.withWeight(weight: weight)
            return customFont ?? NSFont.monospacedSystemFont(ofSize: size, weight: .medium)
        }
    }
}
