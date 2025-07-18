//
//  WorkspaceDocument+SearchState+FindTests.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 26.01.24.
//

import XCTest
@testable import CodeEdit

final class FindTests: XCTestCase {
    private var directory: URL!
    private var files: [CEWorkspaceFile] = []
    private var mockWorkspace: WorkspaceDocument!
    private var searchState: WorkspaceDocument.SearchState!

    // MARK: - Setup
    /// A mock WorkspaceDocument is created
    /// 3 mock files are added to the index
    /// which will be removed in the teardown function
    override func setUp() async throws {
        directory = try FileManager.default.url(
            for: .developerApplicationDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appending(path: "CodeEdit", directoryHint: .isDirectory)
        .appending(path: "WorkspaceClientTests", directoryHint: .isDirectory)
        try? FileManager.default.removeItem(at: directory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        mockWorkspace = try await WorkspaceDocument(for: directory, withContentsOf: directory, ofType: "")
        searchState = await mockWorkspace.searchState

        // Add a few files
        let folder1 = directory.appending(path: "Folder 2")
        let folder2 = directory.appending(path: "Longer Folder With Some 💯 Special Chars ⁉️")
        try FileManager.default.createDirectory(at: folder1, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: folder2, withIntermediateDirectories: true)

        let fileURLs = [
            directory.appending(path: "File 1.txt"),
            folder1.appending(path: "Documentation.docc"),
            folder2.appending(path: "Makefile")
        ]

        for index in 0..<fileURLs.count {
            if index % 2 == 0 {
                try String("Loren Ipsum.").write(to: fileURLs[index], atomically: true, encoding: .utf8)
            } else {
                try String("Aperiam*asperiores").write(to: fileURLs[index], atomically: true, encoding: .utf8)
            }
        }

        files = fileURLs.map { CEWorkspaceFile(url: $0) }

        let parent1 = CEWorkspaceFile(url: folder1)
        let parent2 = CEWorkspaceFile(url: folder2)
        files[1].parent = parent1
        files[2].parent = parent2

        await mockWorkspace.searchState?.addProjectToIndex()

        // The following code also tests whether the workspace is indexed correctly
        // Wait until the index is up to date and flushed
        let startTime = Date()
        let timeoutInSeconds = 2.0
        while searchState.indexStatus != .done {
            // Check every 0.1 seconds for index completion
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            if Date().timeIntervalSince(startTime) > timeoutInSeconds {
                XCTFail("TIMEOUT: Indexing took to long or did not complete.")
                return
            }
        }

        // Retrieve indexed documents from the indexer
        guard let documentsInIndex = searchState.indexer?.documents() else {
            XCTFail("No documents are in the index")
            return
        }

        // Verify that the setup function added the expected number of mock files to the index
        XCTAssertEqual(documentsInIndex.count, 3)
    }

    // MARK: - Tear down
    /// The mock directory along with the mock files will be removed
    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: directory)
    }

    func testGetSearchTerm() {
        let query = "test*/Quer@#y"

        searchState.selectedMode[2] = .Containing
        XCTAssertEqual(searchState.getSearchTerm(query), "*test*quer*y*")

        searchState.selectedMode[2] = .StartingWith
        XCTAssertEqual(searchState.getSearchTerm(query), "test*quer*y*")

        searchState.selectedMode[2] = .EndingWith
        XCTAssertEqual(searchState.getSearchTerm(query), "*test*quer*y")

        searchState.selectedMode[2] = .MatchingWord
        XCTAssertEqual(searchState.getSearchTerm(query), "test*quer*y")

        searchState.caseSensitive = true
        XCTAssertEqual(searchState.getSearchTerm(query), "test*Quer*y")
    }

    func testStripSpecialCharacters() {
        let string = "test!@#Query"
        let strippedString = searchState.stripSpecialCharacters(from: string)
        XCTAssertEqual(strippedString, "test*Query")
    }

    func testGetRegexPattern() {
        let query = "@(test. !*#Query"

        searchState.selectedMode[2] = .Containing
        XCTAssertEqual(searchState.getRegexPattern(query), "@\\(test\\. !\\*#Query")

        searchState.selectedMode[2] = .StartingWith
        XCTAssertEqual(searchState.getRegexPattern(query), "\\b@\\(test\\. !\\*#Query")

        searchState.selectedMode[2] = .EndingWith
        XCTAssertEqual(searchState.getRegexPattern(query), "@\\(test\\. !\\*#Query\\b")

        searchState.selectedMode[2] = .MatchingWord
        XCTAssertEqual(searchState.getRegexPattern(query), "\\b@\\(test\\. !\\*#Query\\b")

        // Enabling case sensitivity shouldn't affect the regex pattern because if case sensitivity is enabled,
        // `NSRegularExpression.Options.caseInsensitive` is passed to `NSRegularExpression`.
        searchState.caseSensitive = true
        XCTAssertEqual(searchState.getRegexPattern(query), "\\b@\\(test\\. !\\*#Query\\b")
    }

    /// Tests the search functionality of the `WorkspaceDocument.SearchState` and `SearchIndexer`.
    func testSearch() async {
        await searchState.search("Ipsum")
        // Wait for the first search expectation to be fulfilled
        await waitForExpectation {
            searchState.searchResult.count == 2
        } onTimeout: {
            XCTFail("Search state did not find two results.")
        }

        await searchState.search("asperiores")
        await waitForExpectation {
            searchState.searchResult.count == 1
        } onTimeout: {
            XCTFail("Search state did not find correct results.")
        }
    }

    /// Checks if the search still returns proper results,
    /// if the search term isn't a complete word
    func testSearchWithOptionContaining() async {
        await searchState.search("psu")
        await waitForExpectation {
            searchState.searchResult.count == 2
        } onTimeout: {
            XCTFail("Search state did not find two results.")
        }

        await searchState.search("erio")
        await waitForExpectation {
            searchState.searchResult.count == 1
        } onTimeout: {
            XCTFail("Search state did not find correct results.")
        }
    }

    /// This test verifies the accuracy of the word search feature.
    /// It first checks for the presence of 'Ipsum,' as done in previous tests.
    /// Following that, it examines the occurrence of the fragment 'perior,'
    /// which is not a complete word in any of the documents
    func testSearchWithOptionMatchingWord() async {
        // Set the search option to 'Matching Word'
        searchState.selectedMode[2] = .MatchingWord

        await searchState.search("Ipsum")
        await waitForExpectation {
            searchState.searchResult.count == 2
        } onTimeout: {
            XCTFail("Search state did not find correct results.")
        }

        // Check if incomplete words return no search results.
        await searchState.search("perior")
        await waitForExpectation {
            searchState.searchResult.isEmpty
        } onTimeout: {
            XCTFail("Search state did not find correct results.")
        }
    }

    func testSearchWithOptionStartingWith() async {
        // Set the search option to 'Starting With'
        searchState.selectedMode[2] = .StartingWith

        await searchState.search("Ip")
        await waitForExpectation {
            searchState.searchResult.count == 2
        } onTimeout: {
            XCTFail("Search state did not find two results.")
        }

        await searchState.search("res")
        await waitForExpectation {
            searchState.searchResult.isEmpty
        } onTimeout: {
            XCTFail("Search state did not find two results.")
        }
    }

    func testSearchWithOptionEndingWith() async {
        // Set the search option to 'Ending with'
        searchState.selectedMode[2] = .EndingWith

        await searchState.search("um")
        await waitForExpectation {
            searchState.searchResult.count == 2
        } onTimeout: {
            XCTFail("Search state did not find two results.")
        }

        await searchState.search("asperi")
        await waitForExpectation {
            searchState.searchResult.isEmpty
        } onTimeout: {
            XCTFail("Search state did not find correct results.")
        }
    }

    func testSearchWithOptionCaseSensitive() async {
        searchState.caseSensitive = true
        await searchState.search("ipsum")
        // Wait for the first search expectation to be fulfilled
        await waitForExpectation {
            // Expecting a result count of 0 due to the intentional use of a lowercase 'i'
            searchState.searchResult.isEmpty
        } onTimeout: {
            XCTFail("Search state did not find correct results.")
        }

        await searchState.search("Asperiores")
        await waitForExpectation {
            // Anticipating zero results since the search is case-sensitive and we used an uppercase 'A'
            searchState.searchResult.isEmpty
        } onTimeout: {
            XCTFail("Search state did not find correct results.")
        }
    }

    // Not implemented yet
    func testSearchWithOptionRegularExpression() async { }
}
