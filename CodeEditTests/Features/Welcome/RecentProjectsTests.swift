//
//  RecentsStoreTests.swift
//  CodeEditTests
//
//  Created by Khan Winter on 5/27/25.
//  Updated for the new RecentsStore on 6/08/25
//

import Testing
import Foundation
@testable import WelcomeWindow   // <- contains RecentsStore

// -----------------------------------------------------------------------------
// MARK: - helpers
// -----------------------------------------------------------------------------

private let testDefaults: UserDefaults = {
    let name = "RecentsStoreTests.\(UUID())"
    let userDefaults   = UserDefaults(suiteName: name)!
    userDefaults.removePersistentDomain(forName: name)   // start clean
    return userDefaults
}()

private extension URL {
    /// Creates an empty file (or directory) on disk, so we can successfully
    /// generate security-scoped bookmarks for it.
    ///
    /// - parameter directory: Pass `true` to create a directory, `false`
    ///                        to create a regular file.
    func materialise(directory: Bool) throws {
        let fileManager = FileManager.default
        if directory {
            try fileManager.createDirectory(at: self, withIntermediateDirectories: true)
        } else {
            fileManager.createFile(atPath: path, contents: Data())
        }
    }

    /// Convenience that returns a fresh URL inside the per-suite temp dir.
    static func temp(named name: String, directory: Bool) -> URL {
        TestContext.tempRoot.appendingPathComponent(
            name,
            isDirectory: directory
        )
    }
}

@MainActor
private func clear() {
    RecentsStore.clearList()
    testDefaults.removeObject(forKey: "recentProjectBookmarks")
}

/// A container for values that need to remain alive for the whole test-suite.
private enum TestContext {
    /// Every run gets its own random temp folder that is cleaned up
    /// when the process exits.
    static let tempRoot: URL = {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("RecentsStoreTests_\(UUID())", isDirectory: true)
        try? FileManager.default.createDirectory(
            at: root,
            withIntermediateDirectories: true
        )
        atexit_b {
            try? FileManager.default.removeItem(at: root)
        }
        return root
    }()
}

// -----------------------------------------------------------------------------
// MARK: - Test-suite
// -----------------------------------------------------------------------------

// Needs to be serial – everything writes to `UserDefaults.standard`.
@Suite(.serialized)
@MainActor
class RecentsStoreTests {

    init() {
        // Redirect the store to the throw-away suite.
        RecentsStore.defaults = testDefaults
        clear()
    }

    deinit {
        Task { @MainActor in
            clear()
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Tests mirroring the old suite
    // -------------------------------------------------------------------------

    @Test
    func newStoreEmpty() {
        clear()
        #expect(RecentsStore.recentProjectURLs().isEmpty)
    }

    @Test
    func savesURLs() throws {
        clear()
        let dir  = URL.temp(named: "Directory", directory: true)
        let file = URL.temp(named: "Directory/file.txt", directory: false)

        try dir.materialise(directory: true)
        try file.materialise(directory: false)

        RecentsStore.documentOpened(at: dir)
        RecentsStore.documentOpened(at: file)

        let recents = RecentsStore.recentProjectURLs()
        #expect(recents.count == 2)
        #expect(recents[0].standardizedFileURL == file.standardizedFileURL)
        #expect(recents[1].standardizedFileURL == dir.standardizedFileURL)
    }

    @Test
    func clearURLs() throws {
        clear()
        let dir  = URL.temp(named: "Directory", directory: true)
        let file = URL.temp(named: "Directory/file.txt", directory: false)

        try dir.materialise(directory: true)
        try file.materialise(directory: false)

        RecentsStore.documentOpened(at: dir)
        RecentsStore.documentOpened(at: file)
        #expect(!RecentsStore.recentProjectURLs().isEmpty)

        RecentsStore.clearList()
        #expect(RecentsStore.recentProjectURLs().isEmpty)
    }

    @Test
    func duplicatesAreMovedToFront() throws {
        clear()
        let dir  = URL.temp(named: "Directory", directory: true)
        let file = URL.temp(named: "Directory/file.txt", directory: false)

        try dir.materialise(directory: true)
        try file.materialise(directory: false)

        RecentsStore.documentOpened(at: dir)
        RecentsStore.documentOpened(at: file)

        // Open `dir` again → should move to front
        RecentsStore.documentOpened(at: dir)
        // Open duplicate again (no change in order, still unique)
        RecentsStore.documentOpened(at: dir)

        let recents = RecentsStore.recentProjectURLs()
        #expect(recents.count == 2)
        #expect(recents[0].standardizedFileURL == dir.standardizedFileURL)
        #expect(recents[1].standardizedFileURL == file.standardizedFileURL)
    }

    @Test
    func removeSubset() throws {
        clear()
        let dir  = URL.temp(named: "Directory", directory: true)
        let file = URL.temp(named: "Directory/file.txt", directory: false)

        try dir.materialise(directory: true)
        try file.materialise(directory: false)

        RecentsStore.documentOpened(at: dir)
        RecentsStore.documentOpened(at: file)

        let remaining = RecentsStore.removeRecentProjects([dir])

        #expect(remaining.count == 1)
        #expect(remaining[0].standardizedFileURL == file.standardizedFileURL)

        let recents = RecentsStore.recentProjectURLs()
        #expect(recents.count == 1)
        #expect(recents[0].standardizedFileURL == file.standardizedFileURL)

    }

    @Test
    func maxesOutAt100Items() throws {
        clear()
        for idx in 0..<101 {
            let isDir = Bool.random()
            let name = "entry_\(idx)" + (isDir ? "" : ".txt")
            let url = URL.temp(named: name, directory: isDir)
            try url.materialise(directory: isDir)
            RecentsStore.documentOpened(at: url)
        }
        #expect(RecentsStore.recentProjectURLs().count == 100)
    }
}
