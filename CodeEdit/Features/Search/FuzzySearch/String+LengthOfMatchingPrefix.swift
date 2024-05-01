//
//  String+LengthOfMatchingPrefix.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 03.02.24.
//

import Foundation

extension String {
    /// Returns the length of the matching prefix content or normalised content at the specified index.
    ///
    /// - Parameters:
    ///   - prefix: The FuzzySearchCharacter whose content or normalised content to check for a prefix match.
    ///   - index: The index from which to start searching for the prefix.
    ///
    /// - Returns: The length of the matching prefix, or nil if no match is found.
    func lengthOfMatchingPrefix(prefix: FuzzySearchCharacter, startingAt index: Int) -> Int? {
        guard let stringIndex = self.index(self.startIndex, offsetBy: index, limitedBy: self.endIndex) else {
            return nil
        }

        let searchString = self.suffix(from: stringIndex)

        for prefix in [prefix.content, prefix.normalisedContent] where searchString.hasPrefix(prefix) {
            return prefix.count
        }

        return nil
    }
}
