//
//  FuzzySearchModels.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 03.02.24.
//

import Foundation

/// FuzzySearchCharacters is used to normalise strings
struct FuzzySearchCharacter {
    let content: String
    // normalised content is referring to a string that is case- and accent-insensitive
    let normalisedContent: String
}

/// FuzzySearchString is just made up by multiple characters, similar to a string, but also with normalised characters
struct FuzzySearchString {
    var characters: [FuzzySearchCharacter]
}

/// FuzzySearchMatchResult represents an object that has undergone a fuzzy search using the fuzzyMatch function.
struct FuzzySearchMatchResult {
    let weight: Int
    let matchedParts: [NSRange]
}
