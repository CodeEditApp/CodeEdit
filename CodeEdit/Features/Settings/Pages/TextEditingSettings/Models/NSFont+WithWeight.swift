//
//  NSFont+WithWeight.swift
//  CodeEdit
//
//  Created by Austin Condiff on 6/17/24.
//

import SwiftUI

extension NSFont {
    /// Rough mapping from behavior of .systemFont(…weight:)
    /// to NSFontManager's Int-based weight, as of 13.4 Ventura
    func withWeight(weight: NSFont.Weight) -> NSFont? {
        let fontManager = NSFontManager.shared
        var intWeight: Int

        switch weight {
        case .ultraLight:
            intWeight=0
        case .light:
            intWeight=2
        case .thin:
            intWeight=3
        case .medium:
            intWeight=6
        case .semibold:
            intWeight=8
        case .bold:
            intWeight=9
        case .heavy:
            intWeight=10
        case .black:
            intWeight=15
        default:
            intWeight=5
        }

        return fontManager.font(
            withFamily: self.familyName ?? "",
            traits: [],
            weight: intWeight,
            size: self.pointSize
        )
    }
}

extension NSFont.Weight: @retroactive Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(CGFloat.self)
        self = NSFont.Weight(rawValue: rawValue)
    }
}
