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
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(searchState.query.searchQuery, "hello")
    }

    func testFindReplaceQuerySyncsBackToSearchQuery() async {
        searchState.query.searchQuery = "world"
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(searchState.searchQuery, "world")
    }

    func testReplaceTextSyncsToFindReplaceQuery() async {
        searchState.replaceText = "replacement"
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(searchState.query.replaceText, "replacement")
    }

    func testFindReplaceQueryReplaceTextSyncsBack() async {
        searchState.query.replaceText = "other"
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(searchState.replaceText, "other")
    }
}
