//
//  FuzzySearchTests.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 03.02.24.
//

import XCTest
@testable import CodeEdit

final class FuzzySearchTests: XCTestCase {
    func testNormalisation() {
        XCTAssertEqual("ü".normalise()[0].normalisedContent, "u")
        XCTAssertEqual("ñ".normalise()[0].normalisedContent, "n")
        XCTAssertEqual("é".normalise()[0].normalisedContent, "e")
    }

    func testFuzzyMatchWeight() {
        guard let url = URL(string: "path/ContentView.swift") else {
            XCTFail("URL could not be created")
            return
        }
        XCTAssert(url.fuzzyMatch(query: "CV").weight > 0)
        XCTAssert(url.fuzzyMatch(query: "conv").weight > 0)
        XCTAssert(url.fuzzyMatch(query: "sw").weight > 0)
        XCTAssert(url.fuzzyMatch(query: "path").weight == 0)
    }

    func testFuzzyMatchRange() {
        guard let url = URL(string: "path/ContentView.swift") else {
            XCTFail("URL could not be created")
            return
        }
        let range = url.fuzzyMatch(query: "ConVie").matchedParts

        XCTAssertEqual(url.lastPathComponent[range[0]], "Con")
        XCTAssertEqual(url.lastPathComponent[range[1]], "Vie")
    }

    func testFuzzySearch() async {
        let urls = [
            URL(string: "FuzzySearchable.swift")!,
            URL(string: "ContentView.swift")!,
            URL(string: "FuzzyMatch.swift")!
        ]
        let fuzzyMatchResult = await urls.fuzzySearch(query: "mch").map {
            $0.item
        }
        XCTAssertEqual(fuzzyMatchResult[0].lastPathComponent, "FuzzyMatch.swift")

        let contentViewResult = await urls.fuzzySearch(query: "CV").map {
            $0.item
        }
        XCTAssertEqual(contentViewResult[0].lastPathComponent, "ContentView.swift")

        let fuzzySearchableResult = await urls.fuzzySearch(query: "seable").map {
            $0.item
        }
        XCTAssertEqual(fuzzySearchableResult[0].lastPathComponent, "FuzzySearchable.swift")

        let swiftResults = await urls.fuzzySearch(query: "swif").map {
            $0.item
        }
        XCTAssertEqual(swiftResults.count, 3)
    }
}
