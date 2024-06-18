//
//  URL+Hardcoded.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 09.06.24.
//

import Foundation

extension URL {
    /// A utility for safely handling hardcoded URLs without using force unwrapping.
    ///
    /// This extension provides a method to create a `URL` from a hardcoded string, ensuring
    /// that the application will terminate with a clear error message if the URL is invalid.
    ///
    /// Usage:
    /// ```swift
    /// let url = URL.hardcoded("https://example.com")
    /// ```
    ///
    /// - Note: This method helps adhere to SwiftLint rules by avoiding force unwrapping.
    static func hardcoded(_ string: String) -> URL {
        let sanitisedString = sanitise(urlString: string)
        guard let url = URL(string: sanitisedString) else {
            fatalError("Invalid URL: \(string)")
        }
        return url
    }

    private static func sanitise(urlString: String) -> String {
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.insert(charactersIn: "/:")

        return urlString.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? ""
    }
}
