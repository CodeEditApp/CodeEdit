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

    /// Compares this url with another, counting the number of shared path components. Stops counting once a
    /// different component is found.
    ///
    /// - Note: URL treats a leading `/` as a component, so `/Users` and `/` will return `1`.
    /// - Parameter other: The URL to compare against.
    /// - Returns: The number of shared components.
    func sharedComponents(_ other: URL) -> Int {
        var count = 0
        for (component, otherComponent) in zip(pathComponents, other.pathComponents) {
            if component == otherComponent {
                count += 1
            } else {
                return count
            }
        }
        return count
    }
}
