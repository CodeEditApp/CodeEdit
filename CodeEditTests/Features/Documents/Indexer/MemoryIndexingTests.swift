//
//  MemoryIndexing.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 08.12.23.
//

import XCTest
@testable import CodeEdit

final class MemoryIndexingTests: XCTestCase {
    func testIndexFile() {
        guard let index = SearchIndexer.Memory.create() else {
            XCTFail("Failed to create an index")
            return
        }

        let filePath = TemporaryFile().url

        let indexResults = index.addFileWithText(filePath, text: "Hello, World!")
        XCTAssert(indexResults)
    }

    func testIndexFiles() {
        guard let index = SearchIndexer.Memory.create() else {
            XCTFail("Failed to create an index")
            return
        }

        let document1 = TemporaryFile().url
        let document2 = TemporaryFile().url

        var indexResults = index.addFileWithText(document1, text: "fileContent")
        XCTAssert(indexResults)
        indexResults = index.addFileWithText(document2, text: "")
        XCTAssert(indexResults)
        index.flush()
        let res = index.cleanUp()
        XCTAssertEqual(res, 1)
    }

    func testIndexFolder() {
        guard let index = SearchIndexer.Memory.create() else {
            XCTFail("Failed to create an index")
            return
        }

        let folder = TempFolderManager()
        folder.createCustomFolder()
        folder.createFiles()

        let indexResults = index.addFolderContent(folderURL: folder.customFolderURL)
        XCTAssertEqual(indexResults.count, 2)

        index.flush()

        let searchResults = index.search("file")
        XCTAssertEqual(searchResults.count, 2, "Unexpected search results")
    }

    func testIndexCleanUp() {
        guard let index = SearchIndexer.Memory.create() else {
            XCTFail("Failed to create an index")
            return
        }

        let document1 = TemporaryFile().url
        let document2 = TemporaryFile().url

        var indexResults = index.addFileWithText(document1, text: "fileContent")
        XCTAssert(indexResults)
        indexResults = index.addFileWithText(document2, text: "")
        XCTAssert(indexResults)
        index.flush()
        let res = index.cleanUp()
        XCTAssertEqual(res, 1)
    }

    func testCloseIndex() {
        guard let index = SearchIndexer.Memory.create() else {
            XCTFail("Failed to create an index")
            return
        }

        let filePath = TemporaryFile().url

        let indexResults = index.addFileWithText(filePath, text: "Hello, World!")
        XCTAssert(indexResults)

        index.close()

        let closedIndexResults = index.addFileWithText(filePath, text: "Hello, World")
        XCTAssertEqual(closedIndexResults, false)
    }

    func testDocumentIsIndex() {
        guard let index = SearchIndexer.Memory.create() else {
            XCTFail("Failed to create an index")
            return
        }

        let filePath = TemporaryFile().url

        let indexResults = index.addFileWithText(filePath, text: "Hello, World!")
        XCTAssert(indexResults)

        let isIndexed = index.documentIndexed(filePath)
        XCTAssertEqual(isIndexed, false)

        index.flush()
        let isIndexedAfterFlush = index.documentIndexed(filePath)
        XCTAssert(isIndexedAfterFlush)
    }

    func testSaveAndLoad() {
        guard let index = SearchIndexer.Memory.create() else {
            XCTFail("Failed to create an index")
            return
        }

        let textFilePath = TemporaryFile().url

        XCTAssertTrue(index.addFileWithText(textFilePath, text: "Illum assumenda iure earum dolorum fugit."))

        index.flush()

        let searchResults = index.search("earum")
        XCTAssertEqual(1, searchResults.count)
        XCTAssertEqual(searchResults[0].url, textFilePath)

        // Save the current index.
        let savedIndex = index.getAsData()
        XCTAssertNotNil(savedIndex, "Failed to save the index.")

        // Close the index, i.e. the index gets deallocated form memory.
        index.close()

        // Load the saved index
        guard let loadedIndex = SearchIndexer.Memory(data: savedIndex!) else {
            XCTFail("Failed to create an index")
            return
        }

        let savedIndexResult = loadedIndex.search("earum")
        XCTAssertEqual(savedIndexResult.count, 1)
    }
}
