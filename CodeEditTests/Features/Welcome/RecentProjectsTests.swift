//
//  RecentProjectsTests.swift
//  CodeEditTests
//
//  Created by Khan Winter on 5/27/25.
//

import Testing
import Foundation
@testable import CodeEdit

class RecentProjectsTests {
    let store: RecentProjectsStore

    init() {
        let defaults = UserDefaults(suiteName: #file)!
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

        #expect(store.recentURLs().count == 2)
        #expect(store.recentURLs()[0].path(percentEncoded: false) == "Directory/")
        #expect(store.recentURLs()[1].path(percentEncoded: false) == "Directory/file.txt")
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
