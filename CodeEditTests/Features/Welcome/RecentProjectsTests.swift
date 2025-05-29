//
//  RecentProjectsTests.swift
//  CodeEditTests
//
//  Created by Khan Winter on 5/27/25.
//

import Testing
import Foundation
@testable import CodeEdit

// This suite needs to be serial due to the use of `UserDefaults` and sharing one testing storage location.
@Suite(.serialized)
class RecentProjectsTests {
    let store: RecentProjectsStore

    init() {
        let defaults = UserDefaults(suiteName: #file)!
        defaults.removeSuite(named: #file)
        store = RecentProjectsStore(defaults: defaults)
    }

    deinit {
        try? FileManager.default.removeItem(atPath: #file + ".plist")
    }

    @Test
    func newStoreEmpty() {
        #expect(store.recentURLs().isEmpty)
    }

    @Test
    func savesURLs() {
        store.documentOpened(at: URL(filePath: "Directory/", directoryHint: .isDirectory))
        store.documentOpened(at: URL(filePath: "Directory/file.txt", directoryHint: .notDirectory))

        let recentURLs = store.recentURLs()
        #expect(recentURLs.count == 2)
        #expect(recentURLs[0].path(percentEncoded: false) == "Directory/file.txt")
        #expect(recentURLs[1].path(percentEncoded: false) == "Directory/")
    }

    @Test
    func clearURLs() {
        store.documentOpened(at: URL(filePath: "Directory/", directoryHint: .isDirectory))
        store.documentOpened(at: URL(filePath: "Directory/file.txt", directoryHint: .notDirectory))

        #expect(store.recentURLs().count == 2)

        store.clearList()

        #expect(store.recentURLs().isEmpty)
    }

    @Test
    func duplicatesAreMovedToFront() {
        store.documentOpened(at: URL(filePath: "Directory/", directoryHint: .isDirectory))
        store.documentOpened(at: URL(filePath: "Directory/file.txt", directoryHint: .notDirectory))
        // Move to front
        store.documentOpened(at: URL(filePath: "Directory/", directoryHint: .isDirectory))
        // Remove duplicate
        store.documentOpened(at: URL(filePath: "Directory/", directoryHint: .isDirectory))

        let recentURLs = store.recentURLs()
        #expect(recentURLs.count == 2)

        // Should be moved to the front of the list because it was 'opened' again.
        #expect(recentURLs[0].path(percentEncoded: false) == "Directory/")
        #expect(recentURLs[1].path(percentEncoded: false) == "Directory/file.txt")
    }

    @Test
    func removeSubset() {
        store.documentOpened(at: URL(filePath: "Directory/", directoryHint: .isDirectory))
        store.documentOpened(at: URL(filePath: "Directory/file.txt", directoryHint: .notDirectory))

        let remaining = store.removeRecentProjects(Set([URL(filePath: "Directory/", directoryHint: .isDirectory)]))

        #expect(remaining == [URL(filePath: "Directory/file.txt")])
        let recentURLs = store.recentURLs()
        #expect(recentURLs.count == 1)
        #expect(recentURLs[0].path(percentEncoded: false) == "Directory/file.txt")
    }

    @Test
    func maxesOutAt100Items() {
        for idx in 0..<101 {
            store.documentOpened(
                at: URL(
                    filePath: "file\(idx).txt",
                    directoryHint: Bool.random() ? .isDirectory : .notDirectory
                )
            )
        }

        #expect(store.recentURLs().count == 100)
    }
}
