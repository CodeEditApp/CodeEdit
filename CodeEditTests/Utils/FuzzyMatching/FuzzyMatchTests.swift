//
//  FuzzyMatchTests.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 03.02.24.
//

import XCTest
import CodeEditCore
@testable import CodeEdit

/// Tests the app's `URL: FuzzyMatchable` conformance (OpenQuickly). The fuzzy-match
/// algorithm itself is covered in CodeEditCore's `CodeEditCoreTests/FuzzyMatchTests`.
final class FuzzyMatchTests: XCTestCase {
    func testFuzzyMatchWeightUsesFileNameOnly() {
        guard let url = URL(string: "path/ContentView.swift") else {
            XCTFail("URL could not be created")
            return
        }
        XCTAssert(url.fuzzyMatch(query: "CV").weight > 0)
        XCTAssert(url.fuzzyMatch(query: "conv").weight > 0)
        XCTAssert(url.fuzzyMatch(query: "sw").weight > 0)
        // Directory components must not match — only the file name is searchable.
        XCTAssert(url.fuzzyMatch(query: "path").weight == 0)
    }

    func testFuzzyMatchRangesIndexIntoFileName() {
        guard let url = URL(string: "path/ContentView.swift") else {
            XCTFail("URL could not be created")
            return
        }
        let range = url.fuzzyMatch(query: "ConVie").matchedParts

        XCTAssertEqual(url.lastPathComponent[range[0]], "Con")
        XCTAssertEqual(url.lastPathComponent[range[1]], "Vie")
    }
}
