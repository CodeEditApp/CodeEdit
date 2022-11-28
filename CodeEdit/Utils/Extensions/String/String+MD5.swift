//
//  String+MD5.swift
//  CodeEditModules/CodeEditUtils
//
//  Created by Nanashi Li on 2022/04/19.
//

import Foundation
import CryptoKit

extension String {

    /// Returns a MD5 encrypted String of the input String
    ///
    /// - Parameters:
    ///   - trim: If `true` the input string will be trimmed from whitespaces and new-lines. Defaults to `false`.
    ///   - caseSensitive: If `false` the input string will be converted to lowercase characters. Defaults to `true`.
    /// - Returns: A String in HEX format
    func md5(trim: Bool = false, caseSensitive: Bool = true) -> String {
        var string = self

        // trim whitespaces & new lines if specifiedå
        if trim { string = string.trimmingCharacters(in: .whitespacesAndNewlines) }

        // make string lowercased if not case sensitive
        if !caseSensitive { string = string.lowercased() }

        // compute the hash
        // (note that `String.data(using: .utf8)!` is safe since it will never fail)
        let computed = Insecure.MD5.hash(data: string.data(using: .utf8)!)

        // map the result to a hex string and return
        return computed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
