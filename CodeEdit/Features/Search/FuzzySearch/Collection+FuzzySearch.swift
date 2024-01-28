//
//  Collection+FuzzySearch.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 27.01.24.
//

import Foundation

extension Collection where Iterator.Element: FuzzySearchable {
    func fuzzySearch(query: String) -> [(result: FuzzySearchMatchResult, item: Iterator.Element)] {
        return map {
            (result: $0.fuzzyMatch(query: query), item: $0)
        }.filter {
            $0.result.weight > 0
        }.sorted {
            $0.result.weight > $1.result.weight
        }
    }
}
