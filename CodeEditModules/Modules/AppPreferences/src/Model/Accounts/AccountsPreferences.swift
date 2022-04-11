//
//  AccountsPreferences.swift
//  
//
//  Created by Nanashi Li on 2022/04/08.
//

import Foundation

public extension AppPreferences {

    /// The global settings for text editing
    struct AccountsPreferences: Codable {
        /// An integer indicating how many spaces a `tab` will generate
        public var defaultTabWidth: Int = 4

        /// The font to use in editor.
        public var font: EditorFont = .init()

        /// Default initializer
        public init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.defaultTabWidth = try container.decodeIfPresent(Int.self, forKey: .defaultTabWidth) ?? 4
            self.font = try container.decodeIfPresent(EditorFont.self, forKey: .font) ?? .init()
        }
    }
}
