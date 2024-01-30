//
//  MemoryIndexSearch.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 08.12.23.
//

import XCTest
@testable import CodeEdit

final class MemoryIndexSearchTests: XCTestCase {
    func testIndexFileSearch() {
        guard let index = SearchIndexer.Memory.create() else {
            XCTFail("Failed to create an index")
            return
        }

        let filePath = TemporaryFile().url

        let indexResults = index.addFileWithText(filePath, text: "Hello, World!")
        XCTAssert(indexResults)
        index.flush()
        let progressiveSearch = index.progressiveSearch(query: "hello")
        let progressiveSearchResults = progressiveSearch.getNextSearchResultsChunk(limit: 10)
        XCTAssertEqual(progressiveSearchResults.results.count, 1)
    }

    func testIndexFolderSearch() {
        guard let index = SearchIndexer.Memory.create() else {
            XCTFail("Failed to create an index")
            return
        }

        let folder = TempFolderManager()
        folder.createCustomFolder()
        folder.createFiles()

        let indexResults = index.addFolderContent(folderURL: folder.customFolderURL)
        XCTAssertEqual(indexResults.count, 2)
    }

    func testIndexFileWildCardSearch() {
        guard let index = SearchIndexer.Memory.create() else {
            XCTFail("Failed to create an index")
            return
        }

        let filePath = TemporaryFile().url

        let indexResults = index.addFileWithText(filePath, text: "Hello, World!")
        XCTAssert(indexResults)
        index.flush()
        let progressiveSearch = index.progressiveSearch(query: "*ll*")
        let progressiveSearchResults = progressiveSearch.getNextSearchResultsChunk(limit: 10)
        XCTAssertEqual(progressiveSearchResults.results.count, 1)
    }

    func testIndexRemoveDocument() {
        guard let index = SearchIndexer.Memory.create() else {
            XCTFail("Failed to create an index")
            return
        }

        let document1 = TemporaryFile().url
        let document2 = TemporaryFile().url
        XCTAssertTrue(index.addFileWithText(document1, text: "Hello, World!"), "Failed to add docs to index.")
        XCTAssertTrue(index.addFileWithText(document2, text: "Hello, Swift!"), "Failed to add docs to index.")

        index.flush()

        let documents = index.documents()
        XCTAssertEqual(documents.count, 2)

        let searchResults = index.search("Hello")
        XCTAssertEqual(searchResults.count, 2, "Unexpected search results.")

        let removeResult = index.removeDocument(url: document1)
        XCTAssertTrue(removeResult, "Failed to remove documents.")

        index.flush()

        let searchResultsAfterFlush = index.search("Hello")
        XCTAssertEqual(searchResultsAfterFlush.count, 1, "Unexpected search results.")
    }
}
