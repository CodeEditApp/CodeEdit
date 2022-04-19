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
    /// - Parameter lowercased: If true this will convert the input string to lowercase characters
    /// - Returns: A String in HEX format
    func md5(_ lowercased: Bool = true) -> String {
        var trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if lowercased { trimmed = trimmed.lowercased() }
        let computed = Insecure.MD5.hash(data: trimmed.data(using: .utf8)!)
        return computed.map { String(format: "%02hhx", $0) }.joined()
    }
}
