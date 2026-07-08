//
//  FuzzySearchModels.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 03.02.24.
//

import Foundation

/// A single character in a fuzzy search string, storing both original and normalised forms.
public struct FuzzySearchCharacter {
    /// The original character content.
    public let content: String
    /// The case- and accent-insensitive form of ``content``.
    public let normalisedContent: String

    /// Creates a ``FuzzySearchCharacter`` with the given original and normalised content.
    public init(content: String, normalisedContent: String) {
        self.content = content
        self.normalisedContent = normalisedContent
    }
}

/// A sequence of ``FuzzySearchCharacter`` values representing a string prepared for fuzzy matching.
public struct FuzzySearchString {
    /// The individual characters that make up this string.
    public var characters: [FuzzySearchCharacter]

    /// Creates a ``FuzzySearchString`` from an array of ``FuzzySearchCharacter`` values.
    public init(characters: [FuzzySearchCharacter]) {
        self.characters = characters
    }
}

/// The result of a fuzzy match operation, containing a relevance weight and the matched ranges.
public struct FuzzySearchMatchResult {
    /// A score indicating how closely the input matched; higher values mean a better match.
    public let weight: Int
    /// The ranges within the original string that were matched.
    public let matchedParts: [NSRange]

    /// Creates a ``FuzzySearchMatchResult`` with the given weight and matched ranges.
    public init(weight: Int, matchedParts: [NSRange]) {
        self.weight = weight
        self.matchedParts = matchedParts
    }
}
