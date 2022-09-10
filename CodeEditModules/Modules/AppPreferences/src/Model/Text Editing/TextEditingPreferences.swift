//
//  TextEditingPreferences.swift
//  CodeEditModules/AppPreferences
//
//  Created by Nanashi Li on 2022/04/08.
//

import Foundation

public extension AppPreferences {

    /// The global settings for text editing
    struct TextEditingPreferences: Codable {
        /// An integer indicating how many spaces a `tab` will generate
        public var defaultTabWidth: Int = 4

        /// The font to use in editor.
        public var font: EditorFont = .init()

        public var enableTypeOverCompletion: Bool = true

        public var autocompleteBraces: Bool = true

        /// Default initializer
        public init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.defaultTabWidth = try container.decodeIfPresent(Int.self, forKey: .defaultTabWidth) ?? 4
            self.font = try container.decodeIfPresent(EditorFont.self, forKey: .font) ?? .init()
            self.enableTypeOverCompletion = try container.decodeIfPresent(
                Bool.self, forKey: .enableTypeOverCompletion) ?? true
            self.autocompleteBraces = try container.decodeIfPresent(Bool.self,
                                                                    forKey: .autocompleteBraces) ?? true
        }
    }

    struct EditorFont: Codable, Equatable {
        /// Indicates whether or not to use a custom font
        public var customFont: Bool = false

        /// The font size for the custom font
        public var size: Int = 11

        /// The name of the custom font
        public var name: String = "SFMono-Medium"

        /// Default initializer
        public init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.customFont = try container.decodeIfPresent(Bool.self, forKey: .customFont) ?? false
            self.size = try container.decodeIfPresent(Int.self, forKey: .size) ?? 11
            self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "SFMono-Medium"
        }
    }
}
