//
//  TemporaryFile.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 08.12.23.
//

import Foundation

class TemporaryFile {
    let url: URL = {
        let folder = NSTemporaryDirectory()
        let name = UUID().uuidString
        
        return NSURL.fileURL(withPathComponents: [folder, name])! as URL
    }()

    deinit {
        try? FileManager.default.removeItem(at: url)
    }
}

class TempFolderManager {
    let temporaryDirectoryURL: URL
    let customFolderURL: URL

    init() {
        self.temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        self.customFolderURL = temporaryDirectoryURL.appendingPathComponent("MyCustomFolder")
    }

    deinit {
        cleanup()
    }
    
    func createCustomFolder() {
        do {
            try FileManager.default.createDirectory(at: customFolderURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating directory: \(error)")
        }
    }

    func createFiles() {
        let file1URL = customFolderURL.appendingPathComponent("file1.txt")
        let file2URL = customFolderURL.appendingPathComponent("file2.txt")

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
            let file1URL = customFolderURL.appendingPathComponent("file1.txt")
            let file2URL = customFolderURL.appendingPathComponent("file2.txt")

            try FileManager.default.removeItem(at: file1URL)
            try FileManager.default.removeItem(at: file2URL)
            try FileManager.default.removeItem(at: customFolderURL)
        } catch {
            print("Error removing item: \(error)")
        }
    }
}
