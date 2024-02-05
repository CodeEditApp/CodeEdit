//
//  Collection+FuzzySearch.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 03.02.24.
//

import Foundation
import CollectionConcurrencyKit

extension Collection where Iterator.Element: FuzzySearchable {
    /// Asynchronously performs a fuzzy search on a collection of elements conforming to FuzzySearchable.
    ///
    /// - Parameter query: The query string to match against the elements.
    ///
    /// - Returns: An array of tuples containing FuzzySearchMatchResult and the corresponding element.
    ///
    /// - Note: Because this is an extension on Collection and not only array,
    /// you can also use this on sets.
    func fuzzySearch(query: String) async -> [(result: FuzzySearchMatchResult, item: Iterator.Element)] {
        return await concurrentMap {
            (result: $0.fuzzyMatch(query: query), item: $0)
        }.filter {
            $0.result.weight > 0
        }.sorted {
            $0.result.weight > $1.result.weight
        }
    }
}
