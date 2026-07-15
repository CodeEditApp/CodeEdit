//
//  TemporaryFile.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 08.12.23.
//

import Foundation

/// A utility class representing a temporary file with automatic cleanup upon deallocation.
///
/// This class provides a convenient way to create a temporary
/// file with a unique name and automatically removes the file when the `TemporaryFile` instance is deallocated.
///
/// Example usage:
/// ```swift
/// let tempFile = TemporaryFile()
/// // Use tempFile.url for file operations
/// // The file will be automatically removed when tempFile is no longer in use.
/// ```
class TemporaryFile {
    /// The URL of the temporary file.
    let url: URL = {
        let folder = NSTemporaryDirectory()
        let name = UUID().uuidString

        return NSURL.fileURL(withPathComponents: [folder, name])! as URL
    }()

    /// Deinitializes the `TemporaryFile` instance and removes the associated temporary file from the filesystem.
    deinit {
        try? FileManager.default.removeItem(at: url)
    }
}

/// A utility class for managing a temporary folder with customizable files.
///
/// The `TempFolderManager` class facilitates the creation, management, 
/// and cleanup of a temporary folder with associated files.
///
/// Example usage:
/// ```swift
/// let folderManager = TempFolderManager()
/// folderManager.createCustomFolder()
/// folderManager.createFiles()
/// // Use files within the custom folder as needed
/// // The folder and files will be automatically cleaned up upon the `TempFolderManager` instance deinitialization.
/// ```
class TempFolderManager {
    let temporaryDirectoryURL: URL
    let customFolderURL: URL

    init() {
        self.temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        self.customFolderURL = temporaryDirectoryURL.appending(path: "TestingFolder")
    }

    deinit {
        cleanup()
    }

    func createCustomFolder() {
        do {
            try FileManager.default.createDirectory(
                at: customFolderURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            print("Error creating directory: \(error)")
        }
    }

    func createFiles() {
        let file1URL = customFolderURL.appending(path: "file1.txt")
        let file2URL = customFolderURL.appending(path: "file2.txt")

        let file1Content = "This is file 1"
        let file2Content = "This is file 2"

        do {
            try file1Content.write(to: file1URL, atomically: true, encoding: .utf8)
            try file2Content.write(to: file2URL, atomically: true, encoding: .utf8)
        } catch {
            print("Error writing to file: \(error)")
        }
    }

    func cleanup() {
        do {
            let file1URL = customFolderURL.appending(path: "file1.txt")
            let file2URL = customFolderURL.appending(path: "file2.txt")

            try FileManager.default.removeItem(at: file1URL)
            try FileManager.default.removeItem(at: file2URL)
            try FileManager.default.removeItem(at: customFolderURL)
        } catch {
            print("Error removing item: \(error)")
        }
    }
}
