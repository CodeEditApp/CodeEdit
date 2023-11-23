//
//  LazyFilePathEnumerator.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 21.11.23.
//

import Foundation

/// A class for lazily enumerating file paths in a directory.

/// - Parameters:
/// - directoryURL: The URL of the directory to enumerate.

/// - Example usage:
/// ```swift
/// let directoryURL = URL(fileURLWithPath: "/path/to/your/directory")
/// let lazyEnumerator = LazyFilePathEnumerator(directoryURL: directoryURL)
///
/// while let filePath = lazyEnumerator.getNextFilePath() {
///     // Process the file path as needed
///     print("Processing file:", filePath.path)
///     // Perform your search or other operations on this file path
/// }
/// ```
class LazyFilePathEnumerator {
    let directoryURL: URL
    var enumerator: FileManager.DirectoryEnumerator?

    init(directoryURL: URL) {
        self.directoryURL = directoryURL
    }

    func getNextFilePath() -> URL? {
        if enumerator == nil {
            enumerator = FileManager.default.enumerator(
                at: directoryURL,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
        }

        return enumerator?.nextObject() as? URL
    }
}
