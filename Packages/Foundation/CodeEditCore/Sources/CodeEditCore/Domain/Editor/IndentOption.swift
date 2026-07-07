//
//  IndentOption.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom.
//

/// The behavior of a `tab` keypress. If `.tab`, inserts a tab character; if `.spaces`,
/// inserts `spaceCount` spaces instead.
///
/// A pure value type shared by the Settings feature and `CodeFileDocument`.
public struct IndentOption: Codable, Hashable, Sendable {
    public var indentType: IndentType
    // Kept even when `indentType` is `.tab` to retain the user's
    // settings when changing `indentType`.
    public var spaceCount: Int

    public init(indentType: IndentType, spaceCount: Int = 4) {
        self.indentType = indentType
        self.spaceCount = spaceCount
    }

    public enum IndentType: String, Codable, Sendable {
        case tab
        case spaces
    }
}
