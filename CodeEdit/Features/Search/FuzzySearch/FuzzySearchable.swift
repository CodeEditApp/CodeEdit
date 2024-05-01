//
//  FuzzySearchable.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 03.02.24.
//

import Foundation

/// A protocol defining the requirements for an object that can be searched using fuzzy matching.
protocol FuzzySearchable {
    var searchableString: String { get }

    /// Performs a fuzzy search on the conforming object's searchable string.
    ///
    /// - Parameters:
    ///   - query: The query string to match against the searchable content.
    ///   - characters: The set of characters used for fuzzy matching.
    ///
    /// - Returns: A FuzzySearchMatchResult indicating the result of the fuzzy search.
    func fuzzyMatch(query: String, characters: FuzzySearchString) -> FuzzySearchMatchResult
}

extension FuzzySearchable {
    func fuzzyMatch(query: String, characters: FuzzySearchString) -> FuzzySearchMatchResult {
        let compareString = characters.characters

        let searchString = query.lowercased()

        var totalScore = 0
        var matchedParts = [NSRange]()

        var patternIndex = 0
        var currentScore = 0
        var currentMatchedPart = NSRange(location: 0, length: 0)

        for (index, character) in compareString.enumerated() {
            if let prefixLength = searchString.lengthOfMatchingPrefix(prefix: character, startingAt: patternIndex) {
                patternIndex += prefixLength
                currentScore += 1
                currentMatchedPart.length += 1
            } else {
                currentScore = 0
                if currentMatchedPart.length != 0 {
                    matchedParts.append(currentMatchedPart)
                }
                currentMatchedPart = NSRange(location: index + 1, length: 0)
            }

            totalScore += currentScore
        }

        if currentMatchedPart.length != 0 {
            matchedParts.append(currentMatchedPart)
        }

        if searchString.count == matchedParts.reduce(0, { partialResult, range in
            range.length + partialResult
        }) {
            return FuzzySearchMatchResult(weight: totalScore, matchedParts: matchedParts)
        } else {
            return FuzzySearchMatchResult(weight: 0, matchedParts: [])
        }
    }

    /// Normalises the searchable string of the conforming object by converting its characters to ASCII representation.
    /// The resulting FuzzySearchString contains both the original and normalised content of each character.
    ///
    /// - Returns: A FuzzySearchString
    func normaliseString() -> FuzzySearchString {
        return FuzzySearchString(characters: searchableString.normalise())
    }

    /// Performs a fuzzy search on the normalised content of the conforming object's searchable string.
    ///
    /// - Parameter query: The query string to match against the normalised searchable content.
    ///
    /// - Returns: A FuzzySearchMatchResult indicating the result of the fuzzy search.
    func fuzzyMatch(query: String) -> FuzzySearchMatchResult {
        let characters = normaliseString()

        return fuzzyMatch(query: query, characters: characters)
    }
}
