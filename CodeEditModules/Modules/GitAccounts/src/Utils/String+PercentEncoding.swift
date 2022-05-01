//
//  String+PercentEncoding.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

extension String {

    /// Percent-encodes a string to be URL-safe
    ///
    /// See https://useyourloaf.com/blog/how-to-percent-encode-a-url-string/ for more info
    /// - returns: An optional string, with percent encoding to match RFC3986
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed)
    }
}
