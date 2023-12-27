//
//  String+AppearancesOfSubstring.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 24.11.23.
//

import Foundation

extension String {
    /// Finds the appearances of a substring within the string.
    /// - Parameters:
    ///   - substring: The substring to search for within the string.
    ///   - toLeft: The optional number of characters to include to the left of each found substring appearance.
    ///   - toRight: The optional number of characters to include to the right of each found substring appearance.
    ///
    ///   - Returns: An array of ranges representing the appearances of the substring within the string.
    func appearancesOfSubstring(substring: String, toLeft: Int=0, toRight: Int=0) -> [Range<String.Index>] {
        guard !substring.isEmpty && self.contains(substring) else { return [] }
        var appearances: [Range<String.Index>] = []
        for (index, character) in self.enumerated() where character == substring.first {
            let startOfFoundCharacter = self.index(self.startIndex, offsetBy: index)
            guard index + substring.count < self.count else { continue }
            let lengthOfFoundCharacter = self.index(self.startIndex, offsetBy: (substring.count + index))
            if self[startOfFoundCharacter..<lengthOfFoundCharacter] == substring {
                let startIndex = self.index(
                    self.startIndex,
                    offsetBy: index - (toLeft <= index ? toLeft : 0)
                )
                let endIndex = self.index(
                    self.startIndex,
                    offsetBy: substring.count + index + (substring.count+index+toRight <= self.count ? toRight : 0)
                )
                appearances.append(startIndex..<endIndex)
            }
        }
        return appearances
    }
}
