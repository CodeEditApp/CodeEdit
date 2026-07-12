//
//  SearchIndexer+Search.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 18.11.23.
//

import Foundation

extension SearchIndexer {
    /// Initiates a search operation based on the provided query.
    ///
    /// - Parameters:
    ///   - query: A string representing the term to be searched for.
    ///   - limit: The maximum number of search results to be returned.
    ///   - timeout: The duration to wait for the search to complete before stopping.
    ///
    /// - Returns: 
    ///     An array of search results, each containing a match URL and its corresponding score,
    ///     indicating the relevance of the match to the query.
    ///
    /// The function performs a search using the specified query,
    /// limiting the number of results based on the provided `limit`.
    /// The `timeout` parameter determines how long the search operation will wait before stopping.
    public func search(
        _ query: String,
        limit: Int = 10,
        timeout: TimeInterval = 1.0,
        options: SKSearchOptions = SKSearchOptions(kSKSearchOptionDefault)
    ) -> [SearchResult] {
        let search = self.progressiveSearch(query: query, options: options)

        var results: [SearchResult] = []
        var moreResultsAvailable = true
        repeat {
            let result = search.getNextSearchResultsChunk(limit: limit, timeout: timeout)
            results.append(contentsOf: result.results)
            moreResultsAvailable = result.moreResultsAvailable
        } while moreResultsAvailable

        return results
    }
}
