//
//  String+MD5.swift
//  
//
//  Created by Nanashi Li on 2022/04/19.
//

import Foundation
import CryptoKit

public extension String {

    /// Returns a MD5 encrypted String of the input String
    ///
    /// - Note: Whitespaces and Newlines are trimmed
    /// - Parameter caseSensitive: If `false` the input string will be converted to lowercase characters.
    /// Defaults to `false`.
    /// - Returns: A String in HEX format
    func md5(_ caseSensitive: Bool = false) -> String {
        var trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if !caseSensitive { trimmed = trimmed.lowercased() }
        let computed = Insecure.MD5.hash(data: trimmed.data(using: .utf8)!)
        return computed.map { String(format: "%02hhx", $0) }.joined()
    }
}
