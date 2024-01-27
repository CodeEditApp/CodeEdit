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
        .appendingPathComponent("CodeEdit", isDirectory: true)
        .appendingPathComponent("WorkspaceClientTests", isDirectory: true)
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
                try String("Loren Ipsum").write(to: fileURLs[index], atomically: true, encoding: .utf8)
            } else {
                try String("Aperiam asperiores").write(to: fileURLs[index], atomically: true, encoding: .utf8)
            }
        }

        files = fileURLs.map { CEWorkspaceFile(url: $0) }

        files[1].parent = CEWorkspaceFile(url: folder1)
        files[2].parent = CEWorkspaceFile(url: folder2)

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

    /// Tests the search functionality of the `WorkspaceDocument.SearchState` and `SearchIndexer`.
    func testSearch() async {
        let searchExpectation = XCTestExpectation(description: "Search for 'Ipsum'")
        let searchExpectation2 = XCTestExpectation(description: "Search for 'asperiores'")

        Task {
            await searchState.search("Ipsum")
            searchExpectation.fulfill()
        }

        // Wait for the first search expectation to be fulfilled
        await fulfillment(of: [searchExpectation], timeout: 10)
        // Retrieve the search results after the first search
        let searchResults = searchState.searchResult

        XCTAssertEqual(searchResults.count, 2)

        Task {
            await searchState.search("asperiores")
            searchExpectation2.fulfill()
        }

        await fulfillment(of: [searchExpectation2], timeout: 10)
        let searchResults2 = searchState.searchResult

        XCTAssertEqual(searchResults2.count, 1)
    }

    /// Checks if the search still returns proper results,
    /// if the search term isn't a complete word
    func testSearchWithOptionContaining() async {
        let searchExpectation = XCTestExpectation(description: "Search for 'psu'")
        let searchExpectation2 = XCTestExpectation(description: "Search for 'erio'")

        Task {
            await searchState.search("psu")
            searchExpectation.fulfill()
        }

        await fulfillment(of: [searchExpectation], timeout: 10)

        let searchResults = searchState.searchResult

        XCTAssertEqual(searchResults.count, 2)

        Task {
            await searchState.search("erio")
            searchExpectation2.fulfill()
        }

        await fulfillment(of: [searchExpectation2], timeout: 10)
        let searchResults2 = searchState.searchResult

        XCTAssertEqual(searchResults2.count, 1)
    }

    /// This test verifies the accuracy of the word search feature.
    /// It first checks for the presence of 'Ipsum,' as done in previous tests.
    /// Following that, it examines the occurrence of the fragment 'perior,'
    /// which is not a complete word in any of the documents
    func testSearchWithOptionMatchingWord() async {
        let searchExpectation = XCTestExpectation(description: "Search for 'Ipsum'")
        let searchExpectation2 = XCTestExpectation(description: "Search for 'perior'")

        // Set the search option to 'Matching Word'
        searchState.selectedMode[2] = .MatchingWord

        Task {
            await searchState.search("Ipsum")
            searchExpectation.fulfill()
        }

        await fulfillment(of: [searchExpectation], timeout: 10)

        let searchResults = searchState.searchResult

        XCTAssertEqual(searchResults.count, 2)

        // Check if incomplete words return no search results.
        Task {
            await searchState.search("perior")
            searchExpectation2.fulfill()
        }

        await fulfillment(of: [searchExpectation2], timeout: 10)
        let searchResults2 = searchState.searchResult

        XCTAssertEqual(searchResults2.count, 0)
    }

    func testSearchWithOptionStartingWith() async {
        let searchExpectation = XCTestExpectation(description: "Search for 'Ip'")
        let searchExpectation2 = XCTestExpectation(description: "Search for 'res'")

        // Set the search option to 'Starting With'
        searchState.selectedMode[2] = .StartingWith

        Task {
            await searchState.search("Ip")
            searchExpectation.fulfill()
        }

        await fulfillment(of: [searchExpectation], timeout: 10)

        let searchResults = searchState.searchResult

        XCTAssertEqual(searchResults.count, 2)

        Task {
            await searchState.search("res")
            searchExpectation2.fulfill()
        }

        await fulfillment(of: [searchExpectation2], timeout: 10)
        let searchResults2 = searchState.searchResult

        XCTAssertEqual(searchResults2.count, 0)
    }

    func testSearchWithOptionEndingWith() async {
        let searchExpectation = XCTestExpectation(description: "Search for 'um'")
        let searchExpectation2 = XCTestExpectation(description: "Search for 'res'")

        // Set the search option to 'Ending with'
        searchState.selectedMode[2] = .EndingWith

        Task {
            await searchState.search("um")
            searchExpectation.fulfill()
        }

        await fulfillment(of: [searchExpectation], timeout: 10)

        let searchResults = searchState.searchResult

        XCTAssertEqual(searchResults.count, 2)

        Task {
            await searchState.search("asperi")
            searchExpectation2.fulfill()
        }

        await fulfillment(of: [searchExpectation2], timeout: 10)
        let searchResults2 = searchState.searchResult

        XCTAssertEqual(searchResults2.count, 0)
    }

    func testSearchWithOptionCaseSensitive() async {
        let searchExpectation = XCTestExpectation(description: "Search for 'Ipsum'")
        let searchExpectation2 = XCTestExpectation(description: "Search for 'asperiores'")

        searchState.caseSensitive = true
        Task {
            await searchState.search("ipsum")
            searchExpectation.fulfill()
        }

        // Wait for the first search expectation to be fulfilled
        await fulfillment(of: [searchExpectation], timeout: 10)
        // Retrieve the search results after the first search
        let searchResults = searchState.searchResult

        // Expecting a result count of 0 due to the intentional use of a lowercase 'i'
        XCTAssertEqual(searchResults.count, 0)

        Task {
            await searchState.search("Asperiores")
            searchExpectation2.fulfill()
        }

        await fulfillment(of: [searchExpectation2], timeout: 10)
        let searchResults2 = searchState.searchResult

        // Anticipating zero results since the search is case-sensitive and we used an uppercase 'A'
        XCTAssertEqual(searchResults2.count, 0)
    }

    // Not implemented yet
    func testSearchWithOptionRegularExpression() async { }
}
