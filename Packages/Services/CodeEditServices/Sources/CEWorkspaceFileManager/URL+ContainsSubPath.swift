//
//  URL+ContainsSubPath.swift
//  CEWorkspaceFileManager
//
//  Created by Khan Winter on 10/22/24.
//

import Foundation

extension URL {
    /// Determines if another URL is lower in the file system than this URL.
    ///
    /// Examples:
    /// ```
    /// URL(filePath: "/Users/Bob/Desktop").containsSubPath(URL(filePath: "/Users/Bob/Desktop/file.txt")) // true
    /// URL(filePath: "/Users/Bob/Desktop").containsSubPath(URL(filePath: "/Users/Bob/Desktop/")) // false
    /// URL(filePath: "/Users/Bob/Desktop").containsSubPath(URL(filePath: "/Users/Bob/")) // false
    /// URL(filePath: "/Users/Bob/Desktop").containsSubPath(URL(filePath: "/Users/Bob/Desktop/Folder")) // true
    /// ```
    ///
    /// - Parameter other: The URL to compare.
    /// - Returns: True, if the other URL is lower in the file system.
    func containsSubPath(_ other: URL) -> Bool {
        other.absoluteString.starts(with: absoluteString)
        && other.pathComponents.count > pathComponents.count
    }
}
