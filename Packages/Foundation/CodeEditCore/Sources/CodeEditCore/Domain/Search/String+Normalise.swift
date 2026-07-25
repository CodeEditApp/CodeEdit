//
//  String+Normalise.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 03.02.24.
//

import Foundation

public extension String {
    /// Normalises the characters of the string by converting them to ASCII representation.
    /// Each character is transformed into its ASCII equivalent, and the resulting array
    /// of FuzzyMatchCharacter objects contains both the original and normalised content.
    ///
    /// - Returns: An array of FuzzyMatchCharacter objects representing the original and
    /// normalised content of each character in the string.
    func normalise() -> [FuzzyMatchCharacter] {
        return self.lowercased().map { char in
            guard let data = String(char).data(using: .ascii, allowLossyConversion: true),
                  let normalisedCharacter = String(data: data, encoding: .ascii) else {
                return FuzzyMatchCharacter(content: String(char), normalisedContent: String(char))
            }

            return FuzzyMatchCharacter(content: String(char), normalisedContent: normalisedCharacter)
        }
    }
}
