//
//  Models.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 27.01.24.
//

import Foundation

/// FuzzySearchCharacters is used to normalise strings
struct FuzzySearchCharacter {
    let content: String
    // normalised content is referring to a string that is case- and accent-insensitive
    let normalisedContent: String
}

/// FuzzySearchString is just made up by multiple characters
struct FuzzySearchString {
    var characters: [FuzzySearchCharacter]
}

struct FuzzySearchMatchResult {
    let weight: Int
    let matchedParts: [NSRange]
}
