//
//  FuzzySearchable.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 27.01.24.
//

import Foundation

protocol FuzzySearchable {
    var searchableString: String { get }

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

    func normaliseString() -> FuzzySearchString {
        return FuzzySearchString(characters: searchableString.normalise())
    }

    func fuzzyMatch(query: String) -> FuzzySearchMatchResult {
        let characters = normaliseString()

        return fuzzyMatch(query: query, characters: characters)
    }
}
