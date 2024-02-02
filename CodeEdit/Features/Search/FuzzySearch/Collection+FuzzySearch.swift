//
//  Collection+FuzzySearch.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 27.01.24.
//

import Foundation
import CollectionConcurrencyKit

extension Collection where Iterator.Element: FuzzySearchable {
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
