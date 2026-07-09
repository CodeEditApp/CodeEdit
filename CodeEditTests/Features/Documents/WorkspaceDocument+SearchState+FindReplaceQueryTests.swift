//
//  WorkspaceDocument+SearchState+FindReplaceQueryTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom.
//

import XCTest
import CodeEditCore
import Search

final class FindReplaceQueryBridgeTests: XCTestCase {
    private var directory: URL!
    private var searchState: SearchState!

    override func setUp() async throws {
        directory = try FileManager.default.url(
            for: .developerApplicationDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appending(path: "CodeEdit", directoryHint: .isDirectory)
        .appending(path: "FindReplaceQueryBridgeTests", directoryHint: .isDirectory)
        try? FileManager.default.removeItem(at: directory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        searchState = SearchState(workspaceURL: directory)

        // Wait for indexing to settle before the test starts mutating state, to avoid racing
        // background indexing work against the next test's setUp/tearDown on the same directory.
        let startTime = Date()
        let timeoutInSeconds = 2.0
        while searchState.indexStatus != .done {
            try? await Task.sleep(nanoseconds: 100_000_000)
            if Date().timeIntervalSince(startTime) > timeoutInSeconds {
                XCTFail("TIMEOUT: Indexing took too long or did not complete.")
                return
            }
        }
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: directory)
        searchState = nil
    }

    func testSearchQueryStartsEmptyOnBothSides() {
        XCTAssertEqual(searchState.searchQuery, "")
        XCTAssertEqual(searchState.query.searchQuery, "")
    }

    func testSearchQuerySyncsToFindReplaceQuery() async {
        searchState.searchQuery = "hello"
        await waitUntil { self.searchState.query.searchQuery == "hello" }
        XCTAssertEqual(searchState.query.searchQuery, "hello")
    }

    func testFindReplaceQuerySyncsBackToSearchQuery() async {
        searchState.query.searchQuery = "world"
        await waitUntil { self.searchState.searchQuery == "world" }
        XCTAssertEqual(searchState.searchQuery, "world")
    }

    func testReplaceTextSyncsToFindReplaceQuery() async {
        searchState.replaceText = "replacement"
        await waitUntil { self.searchState.query.replaceText == "replacement" }
        XCTAssertEqual(searchState.query.replaceText, "replacement")
    }

    func testFindReplaceQueryReplaceTextSyncsBack() async {
        searchState.query.replaceText = "other"
        await waitUntil { self.searchState.replaceText == "other" }
        XCTAssertEqual(searchState.replaceText, "other")
    }

    /// Polls `condition` until it's true or 2 seconds elapse, yielding to the run loop between checks so
    /// `.receive(on: RunLoop.main)`-scheduled Combine work actually gets a chance to run.
    private func waitUntil(timeout: TimeInterval = 2, _ condition: @escaping () -> Bool) async {
        let startTime = Date()
        while !condition() {
            try? await Task.sleep(nanoseconds: 20_000_000)
            if Date().timeIntervalSince(startTime) > timeout {
                XCTFail("TIMEOUT: Condition did not become true within \(timeout) seconds.")
                return
            }
        }
    }
}
