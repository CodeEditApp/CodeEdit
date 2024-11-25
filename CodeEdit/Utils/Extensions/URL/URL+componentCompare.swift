//
//  URL+componentCompare.swift
//  CodeEdit
//
//  Created by Khan Winter on 10/22/24.
//

import Foundation

extension URL {
    /// Compare a URL using its path components.
    /// - Parameter other: The URL to compare to
    /// - Returns: `true` if the URL points to the same path on disk. Regardless of query parameters, trailing
    ///            slashes, etc.
    func componentCompare(_ other: URL) -> Bool {
        return self.pathComponents == other.pathComponents
    }
}
