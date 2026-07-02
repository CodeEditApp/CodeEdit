//
//  FuzzySearchModels.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 03.02.24.
//

import Foundation

/// FuzzySearchCharacters is used to normalise strings
public struct FuzzySearchCharacter {
    public let content: String
    // normalised content is referring to a string that is case- and accent-insensitive
    public let normalisedContent: String

    public init(content: String, normalisedContent: String) {
        self.content = content
        self.normalisedContent = normalisedContent
    }
}

/// FuzzySearchString is just made up by multiple characters, similar to a string, but also with normalised characters
public struct FuzzySearchString {
    public var characters: [FuzzySearchCharacter]

    public init(characters: [FuzzySearchCharacter]) {
        self.characters = characters
    }
}

/// FuzzySearchMatchResult represents an object that has undergone a fuzzy search using the fuzzyMatch function.
public struct FuzzySearchMatchResult {
    public let weight: Int
    public let matchedParts: [NSRange]

    public init(weight: Int, matchedParts: [NSRange]) {
        self.weight = weight
        self.matchedParts = matchedParts
    }
}
