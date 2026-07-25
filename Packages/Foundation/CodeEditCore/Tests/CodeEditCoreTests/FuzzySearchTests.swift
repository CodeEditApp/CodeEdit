//
//  FuzzyMatchTests.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 15/07/26.
//

import Testing
import Foundation
import CodeEditCore

private struct TestSearchable: FuzzyMatchable, Sendable, Equatable {
    let id: Int
    let searchableString: String

    init(_ id: Int = 0, _ searchableString: String) {
        self.id = id
        self.searchableString = searchableString
    }
}

struct FuzzyMatchTests {
    @Test func normalisation() {
        #expect("ü".normalise()[0].normalisedContent == "u")
        #expect("ñ".normalise()[0].normalisedContent == "n")
        #expect("é".normalise()[0].normalisedContent == "e")
    }

    @Test func matchWeightReflectsContainment() {
        let item = TestSearchable(0, "ContentView.swift")
        #expect(item.fuzzyMatch(query: "CV").weight > 0)
        #expect(item.fuzzyMatch(query: "conv").weight > 0)
        #expect(item.fuzzyMatch(query: "xyz").weight == 0)
    }

    @Test func matchedPartsCoverTheQuery() {
        let item = TestSearchable(0, "ContentView.swift")
        let string = item.searchableString

        let substrings = item.fuzzyMatch(query: "ConVie").matchedParts.compactMap { part in
            Range(part, in: string).map { String(string[$0]) }
        }

        #expect(substrings == ["Con", "Vie"])
    }

    @Test func searchSortsByDescendingWeightAndDropsNonMatches() async {
        let items = [
            TestSearchable(0, "FuzzyMatchable.swift"),
            TestSearchable(1, "README.md"),
            TestSearchable(2, "FuzzyMatch.swift")
        ]

        let results = await items.fuzzyMatches(query: "fuzzy")

        #expect(results.count == 2)
        #expect(results.allSatisfy { $0.result.weight > 0 })
        #expect(results.map(\.result.weight) == results.map(\.result.weight).sorted(by: >))
    }

    @Test func searchPreservesInputOrderForEqualWeights() async {
        // Identical searchable strings produce identical weights; the sort is stable,
        // so the result order must match the input order.
        let items = (0..<50).map { TestSearchable($0, "SameName.swift") }

        let results = await items.fuzzyMatches(query: "same").map(\.item)

        #expect(results == items)
    }
}
