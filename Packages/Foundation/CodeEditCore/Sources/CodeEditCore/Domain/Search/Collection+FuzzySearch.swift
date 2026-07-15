//
//  Collection+FuzzySearch.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 03.02.24.
//

import Foundation

public extension Collection where Element: FuzzySearchable & Sendable {
    /// Concurrently performs a fuzzy search on a collection of elements conforming to FuzzySearchable.
    ///
    /// - Parameter query: The query string to match against the elements.
    ///
    /// - Returns: Matching elements (weight > 0) paired with their match results, sorted by
    ///   descending weight. Elements with equal weight keep their input order.
    ///
    /// - Note: Because this is an extension on Collection and not only array,
    /// you can also use this on sets.
    func fuzzySearch(query: String) async -> [(result: FuzzySearchMatchResult, item: Element)] {
        let items = Array(self)

        let matches = await withTaskGroup(of: (Int, FuzzySearchMatchResult).self) { group in
            for (index, item) in items.enumerated() {
                group.addTask {
                    (index, item.fuzzyMatch(query: query))
                }
            }

            var results = [FuzzySearchMatchResult?](repeating: nil, count: items.count)
            for await (index, result) in group {
                results[index] = result
            }
            return results
        }

        return zip(matches, items)
            .compactMap { match, item in match.map { (result: $0, item: item) } }
            .filter { $0.result.weight > 0 }
            .sorted { $0.result.weight > $1.result.weight }
    }
}
