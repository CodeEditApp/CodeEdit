//
//  WorkspaceDocument+SearchState+IndexTests.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 26.01.24.
//

import XCTest
@testable import CodeEdit

final class WorkspaceDocumentIndexTests: XCTestCase {
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

    // Actually already tested in the setUp function, but for the sake of completeness
    func testAddWorkspaceToIndex() {
        // Retrieve indexed documents from the indexer
        guard let documentsInIndex = searchState.indexer?.documents() else {
            XCTFail("No documents are in the index")
            return
        }

        // Verify that the setup function added the expected number of mock files to the index
        XCTAssertEqual(documentsInIndex.count, 3)
    }

    // The SearchState+Indexing file isn't complete yet
    // So as it expands more tests will be added here
}
