//
//  String+Character.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 24.11.23.
//

import Foundation

extension String {
    /// Retrieves the character at the specified index within the string.
    /// - Parameter index: The index of the character to retrieve.
    /// - Returns: The character at the specified index.
    func character(at index: Int) -> Character? {
        guard index < self.count else {
            return nil
        }

        return self[self.index(self.startIndex, offsetBy: index)]
    }
}
