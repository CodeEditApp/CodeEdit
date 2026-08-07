//
//  String+Lines.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/17/23.
//

import Foundation

extension String {
    /// Calculates the first `n` lines and returns them as a new string.
    /// - Parameters:
    ///   - lines: The number of lines to return.
    ///   - maxLength: The maximum number of characters to copy.
    /// - Returns: A new string containing the lines.
    func getFirstLines(_ lines: Int = 1, maxLength: Int = 512) -> String {
        var string = ""
        var foundLines = 0
        var totalLength = 0
        for char in self.lazy {
            if char.isNewline {
                foundLines += 1
            }
            totalLength += 1
            if foundLines >= lines || totalLength >= maxLength {
                break
            }
            string.append(char)
        }
        return string
    }

    /// Calculates the last `n` lines and returns them as a new string.
    /// - Parameters:
    ///   - lines: The number of lines to return.
    ///   - maxLength: The maximum number of characters to copy.
    /// - Returns: A new string containing the lines.
    func getLastLines(_ lines: Int = 1, maxLength: Int = 512) -> String {
        var string = ""
        var foundLines = 0
        var totalLength = 0
        for char in self.lazy.reversed() {
            if char.isNewline {
                foundLines += 1
            }
            totalLength += 1
            if foundLines >= lines || totalLength >= maxLength {
                break
            }
            string = String(char) + string
        }
        return string
    }
}
