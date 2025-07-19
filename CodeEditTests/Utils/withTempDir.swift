//
//  withTempDir.swift
//  CodeEditTests
//
//  Created by Khan Winter on 7/3/25.
//

import Foundation
import Testing

func withTempDir(_ test: (URL) async throws -> Void) async throws {
    guard let currentTest = Test.current else {
        #expect(Bool(false))
        return
    }
    let tempDirURL = try createAndClearDir(file: currentTest.sourceLocation.fileID + currentTest.name)
    do {
        try await test(tempDirURL)
    } catch {
        try clearDir(tempDirURL)
        throw error
    }
    try clearDir(tempDirURL)
}

func withTempDir(_ test: (URL) throws -> Void) throws {
    guard let currentTest = Test.current else {
        #expect(Bool(false))
        return
    }
    let tempDirURL = try createAndClearDir(file: currentTest.sourceLocation.fileID + currentTest.name)
    do {
        try test(tempDirURL)
    } catch {
        try clearDir(tempDirURL)
        throw error
    }
    try clearDir(tempDirURL)
}

private func createAndClearDir(file: String) throws -> URL {
    let file = file.components(separatedBy: CharacterSet(charactersIn: "/:?%*|\"<>")).joined()
    let tempDirURL = FileManager.default.temporaryDirectory
        .appending(path: "CodeEditTestDirectory" + file, directoryHint: .isDirectory)

    // If it exists, delete it before the test
    try clearDir(tempDirURL)

    try FileManager.default.createDirectory(at: tempDirURL, withIntermediateDirectories: true)

    return tempDirURL
}

private func clearDir(_ url: URL) throws {
    if FileManager.default.fileExists(atPath: url.absoluteURL.path(percentEncoded: false)) {
        try FileManager.default.removeItem(at: url)
    }
}
