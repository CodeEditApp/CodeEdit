//
//  FuzzyMatchable.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 03.02.24.
//

import Foundation

/// A protocol defining the requirements for an object that can be searched using fuzzy matching.
public protocol FuzzyMatchable {
    /// The string content that fuzzy matches are made against.
    var searchableString: String { get }

    /// Performs a fuzzy match against the conforming object's searchable string.
    ///
    /// - Parameters:
    ///   - query: The query string to match against the searchable content.
    ///   - characters: The set of characters used for fuzzy matching.
    ///
    /// - Returns: A FuzzyMatchResult indicating the result of the fuzzy match.
    func fuzzyMatch(query: String, characters: FuzzyMatchString) -> FuzzyMatchResult
}

public extension FuzzyMatchable {
    /// Default implementation scoring consecutive character matches; returns a zero-weight result
    /// when the query is not fully contained in the searchable string.
    func fuzzyMatch(query: String, characters: FuzzyMatchString) -> FuzzyMatchResult {
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
            return FuzzyMatchResult(weight: totalScore, matchedParts: matchedParts)
        } else {
            return FuzzyMatchResult(weight: 0, matchedParts: [])
        }
    }

    /// Normalises the searchable string of the conforming object by converting its characters to ASCII representation.
    /// The resulting FuzzyMatchString contains both the original and normalised content of each character.
    ///
    /// - Returns: A FuzzyMatchString
    func normaliseString() -> FuzzyMatchString {
        return FuzzyMatchString(characters: searchableString.normalise())
    }

    /// Performs a fuzzy match against the normalised content of the conforming object's searchable string.
    ///
    /// - Parameter query: The query string to match against the normalised searchable content.
    ///
    /// - Returns: A FuzzyMatchResult indicating the result of the fuzzy match.
    func fuzzyMatch(query: String) -> FuzzyMatchResult {
        let characters = normaliseString()

        return fuzzyMatch(query: query, characters: characters)
    }
}
