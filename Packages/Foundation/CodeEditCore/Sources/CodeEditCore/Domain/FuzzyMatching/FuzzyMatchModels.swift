//
//  FuzzyMatchModels.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 03.02.24.
//

import Foundation

/// A single character in a fuzzy match string, storing both original and normalised forms.
public struct FuzzyMatchCharacter {
    /// The original character content.
    public let content: String
    /// The case- and accent-insensitive form of ``content``.
    public let normalisedContent: String

    /// Creates a ``FuzzyMatchCharacter`` with the given original and normalised content.
    public init(content: String, normalisedContent: String) {
        self.content = content
        self.normalisedContent = normalisedContent
    }
}

/// A sequence of ``FuzzyMatchCharacter`` values representing a string prepared for fuzzy matching.
public struct FuzzyMatchString {
    /// The individual characters that make up this string.
    public var characters: [FuzzyMatchCharacter]

    /// Creates a ``FuzzyMatchString`` from an array of ``FuzzyMatchCharacter`` values.
    public init(characters: [FuzzyMatchCharacter]) {
        self.characters = characters
    }
}

/// The result of a fuzzy match operation, containing a relevance weight and the matched ranges.
public struct FuzzyMatchResult: Sendable {
    /// A score indicating how closely the input matched; higher values mean a better match.
    public let weight: Int
    /// The ranges within the original string that were matched.
    public let matchedParts: [NSRange]

    /// Creates a ``FuzzyMatchResult`` with the given weight and matched ranges.
    public init(weight: Int, matchedParts: [NSRange]) {
        self.weight = weight
        self.matchedParts = matchedParts
    }
}
