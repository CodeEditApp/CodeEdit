//
//  WorkspaceDocument+SearchState+FindAndReplaceTests.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 26.01.24.
//

import XCTest
@testable import CodeEdit

@MainActor
final class FindAndReplaceTests: XCTestCase { // swiftlint:disable:this type_body_length
    private var directory: URL!
    private var files: [CEWorkspaceFile] = []
    private var mockWorkspace: WorkspaceDocument!
    private var searchState: WorkspaceDocument.SearchState!

    private var folder1File: CEWorkspaceFile?
    private var folder2File: CEWorkspaceFile?

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

        mockWorkspace = try WorkspaceDocument(for: directory, withContentsOf: directory, ofType: "")
        searchState = mockWorkspace.searchState

        // Add a few files
        let folder1 = directory.appending(path: "Folder 2")
        folder1File = CEWorkspaceFile(url: folder1)
        let folder2 = directory.appending(path: "Longer Folder With Some 💯 Special Chars ⁉️")
        folder2File = CEWorkspaceFile(url: folder2)
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

        files[1].parent = folder1File
        files[2].parent = folder2File

        mockWorkspace.searchState?.addProjectToIndex()

        // NOTE: This is a temporary solution. In the future, a file watcher should track file updates
        // and trigger an index update.
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

    func reIndexWorkspace() async {
        // IMPORTANT:
        // This is only a temporary solution, in the feature a file watcher would track the file update
        // and trigger a index update.
        searchState.addProjectToIndex()
        let startTime = Date()
        while searchState.indexStatus != .done {
            try? await Task.sleep(nanoseconds: 100_000_000)
            if Date().timeIntervalSince(startTime) > 2.0 {
                XCTFail("TIMEOUT: Indexing took to long or did not complete.")
                return
            }
        }
    }

    func testFindAndReplace() async {
        let findAndReplaceExpectation = XCTestExpectation(description: "Find and replace")

        Task {
            do {
                try await searchState.findAndReplace(query: "Ipsum", replacingTerm: "muspi")
            } catch {
                XCTFail("Find and replace failed: \(error.localizedDescription)")
                return
            }
            findAndReplaceExpectation.fulfill()
        }

        await fulfillment(of: [findAndReplaceExpectation], timeout: 2)

        await reIndexWorkspace()

        let searchExpectation = XCTestExpectation(
            description: "Search for the new term that replaced 'Ipsum'('muspi')."
        )

        Task {
            await searchState.search("muspi")
            searchExpectation.fulfill()
        }

        await fulfillment(of: [searchExpectation], timeout: 2)
        let searchResults = searchState.searchResult

        // Expecting a result count of 0 due to the intentional use of a lowercase 'i'
        XCTAssertEqual(searchResults.count, 2)
    }

    func testFindAndReplaceWithOptionContaining() async {
        let findAndReplaceExpectation = XCTestExpectation(description: "Find and replace")

        Task {
            do {
                try await searchState.findAndReplace(query: "psu", replacingTerm: "OOO")
            } catch {
                XCTFail("Find and replace failed: \(error.localizedDescription)")
                return
            }
            findAndReplaceExpectation.fulfill()
        }

        await fulfillment(of: [findAndReplaceExpectation], timeout: 2)

        await reIndexWorkspace()

        let searchExpectation = XCTestExpectation(
            description: "Search for the new term that replaced 'Ipsum'('IOOOm')."
        )

        Task {
            await searchState.search("IOOOm")
            searchExpectation.fulfill()
        }

        await fulfillment(of: [searchExpectation], timeout: 2)
        let searchResults = searchState.searchResult

        XCTAssertEqual(searchResults.count, 2)
    }

    func testFindAndReplaceWithOptionMatchingWord() async {
        let failedFindAndReplaceExpectation = XCTestExpectation(description: "Failed Find and replace")
        let successfulFindAndReplaceExpectation = XCTestExpectation(description: "Successful Find and replace")

        searchState.selectedMode[2] = .MatchingWord

        Task {
            do {
                // this replacement should fail due to the .MatchingWord option
                try await searchState.findAndReplace(query: "psu", replacingTerm: "OOO")
            } catch {
                XCTFail("Find and replace failed: \(error.localizedDescription)")
                return
            }
            failedFindAndReplaceExpectation.fulfill()
        }

        await fulfillment(of: [failedFindAndReplaceExpectation], timeout: 2)

        await reIndexWorkspace()

        let searchExpectation = XCTestExpectation(description: "Search for replaced word.")

        Task {
            await searchState.search("IOOOm")
            searchExpectation.fulfill()
        }

        await fulfillment(of: [searchExpectation], timeout: 2)
        let searchResults = searchState.searchResult

        // Expecting a result count of 0 due to the intentional use of a incomplete word, while using .MatchingWord
        XCTAssertEqual(searchResults.count, 0)

        Task {
            do {
                // This should replace Ipsum correctly, because Ipsum is a whole word in 2 of the mock-documents
                try await searchState.findAndReplace(query: "Ipsum", replacingTerm: "OOO")
            } catch {
                XCTFail("Find and replace failed: \(error.localizedDescription)")
                return
            }
            successfulFindAndReplaceExpectation.fulfill()
        }

        await fulfillment(of: [successfulFindAndReplaceExpectation])

        await reIndexWorkspace()

        let searchExpectation2 = XCTestExpectation(
            description: "Search for the new term that replaced 'Ipsum'('OOO')."
        )

        Task {
            await searchState.search("OOO")
            searchExpectation2.fulfill()
        }

        await fulfillment(of: [searchExpectation2], timeout: 2)
        let searchResults2 = searchState.searchResult

        // 'Ipsum' got replaced by '000' so we expecting 2 results(000 appears in two documents)
        XCTAssertEqual(searchResults2.count, 2)
    }

    func testFindAndReplaceWithOptionStartingWith() async {
        let failedFindAndReplaceExpectation = XCTestExpectation(description: "Failed Find and replace")
        let successfulFindAndReplaceExpectation = XCTestExpectation(description: "Successful Find and replace")

        searchState.selectedMode[2] = .StartingWith

        Task {
            do {
                // this replacement should fail due to the .StartingWith option
                try await searchState.findAndReplace(query: "psum", replacingTerm: "OOO")
            } catch {
                XCTFail("Find and replace failed: \(error.localizedDescription)")
                return
            }
            failedFindAndReplaceExpectation.fulfill()
        }

        await fulfillment(of: [failedFindAndReplaceExpectation], timeout: 2)

        await reIndexWorkspace()

        let searchExpectation = XCTestExpectation(description: "Search for replaced word.")

        Task {
            await searchState.search("OOO")
            searchExpectation.fulfill()
        }

        await fulfillment(of: [searchExpectation], timeout: 2)
        let searchResults = searchState.searchResult

        // Expecting a result count of 0 due to the intentional use of a incomplete word, while using .MatchingWord
        XCTAssertEqual(searchResults.count, 0)

        Task {
            do {
                // This should replace 'Ipsu' with '000' and result in '000m'
                try await searchState.findAndReplace(query: "Ipsu", replacingTerm: "OOO")
            } catch {
                XCTFail("Find and replace failed: \(error.localizedDescription)")
                return
            }
            successfulFindAndReplaceExpectation.fulfill()
        }

        await fulfillment(of: [successfulFindAndReplaceExpectation])

        await reIndexWorkspace()

        let searchExpectation2 = XCTestExpectation(
            description: "Search for the new term that replaced 'Ipsum'('OOO')."
        )

        Task {
            // Note that we are searching for '000m' instead of '000' to test that the whole word did not got replaced
            await searchState.search("OOOm")
            searchExpectation2.fulfill()
        }

        await fulfillment(of: [searchExpectation2], timeout: 2)
        let searchResults2 = searchState.searchResult

        XCTAssertEqual(searchResults2.count, 2)
    }

    func testFindAndReplaceWithOptionEndingWith() async {
        let failedFindAndReplaceExpectation = XCTestExpectation(description: "Failed Find and replace")
        let successfulFindAndReplaceExpectation = XCTestExpectation(description: "Successful Find and replace")

        searchState.selectedMode[2] = .EndingWith

        Task {
            do {
                // this replacement should fail due to the .EndingWith option
                try await searchState.findAndReplace(query: "Ipsu", replacingTerm: "OOO")
            } catch {
                XCTFail("Find and replace failed: \(error.localizedDescription)")
                return
            }
            failedFindAndReplaceExpectation.fulfill()
        }

        await fulfillment(of: [failedFindAndReplaceExpectation], timeout: 2)

        await reIndexWorkspace()

        let searchExpectation = XCTestExpectation(description: "Search for replaced word.")

        Task {
            await searchState.search("OOO")
            searchExpectation.fulfill()
        }

        await fulfillment(of: [searchExpectation], timeout: 2)
        let searchResults = searchState.searchResult

        // Expecting a result count of 0 due to the intentional use of a incomplete word, while using .MatchingWord
        XCTAssertEqual(searchResults.count, 0)

        Task {
            do {
                // This should replace 'Ipsu' with '000' and result in '000m'
                try await searchState.findAndReplace(query: "sum", replacingTerm: "OOO")
            } catch {
                XCTFail("Find and replace failed: \(error.localizedDescription)")
                return
            }
            successfulFindAndReplaceExpectation.fulfill()
        }

        await fulfillment(of: [successfulFindAndReplaceExpectation])

        await reIndexWorkspace()

        let searchExpectation2 = XCTestExpectation(
            description: "Search for the new term that replaced 'Ipsum'('OOO')."
        )

        Task {
            // Test that the entire word 'Ipsum' is not replaced by searching for 'Ip000'.
            await searchState.search("IpOOO")
            searchExpectation2.fulfill()
        }

        await fulfillment(of: [searchExpectation2], timeout: 2)
        let searchResults2 = searchState.searchResult

        XCTAssertEqual(searchResults2.count, 2)
    }

    // Not implemented
    func testFindAndReplaceWithOptionRegularExpression() async { }
}
