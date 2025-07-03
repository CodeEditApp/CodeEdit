//
//  withTempDir.swift
//  CodeEditTests
//
//  Created by Khan Winter on 7/3/25.
//

import Foundation

func withTempDir(_ test: (URL) async throws -> Void) async throws {
    let tempDirURL = try createAndClearDir()
    do {
        try await test(tempDirURL)
    } catch {
        try clearDir(tempDirURL)
        throw error
    }
    try clearDir(tempDirURL)
}

func withTempDir(_ test: (URL) throws -> Void) throws {
    let tempDirURL = try createAndClearDir()
    do {
        try test(tempDirURL)
    } catch {
        try clearDir(tempDirURL)
        throw error
    }
    try clearDir(tempDirURL)
}

private func createAndClearDir() throws -> URL {
    let tempDirURL = try FileManager.default.url(
        for: .developerApplicationDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    )
        .appending(path: "CodeEditTestDirectory", directoryHint: .isDirectory)

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
