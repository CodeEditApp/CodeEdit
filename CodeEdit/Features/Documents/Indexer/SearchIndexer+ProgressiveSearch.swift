//
//  SearchIndexer+ProgressiveSearch.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 18.11.23.
//

import Foundation

extension SearchIndexer {
    /// Object representing the search results
    public class SearchResult {
        /// The identifying url for the document
        let url: URL

        /// The search score for the document, higher means more relevant
        let score: Float

        init(url: URL, score: Float) {
            self.url = url
            self.score = score
        }
    }

    /// Start a progressive search
    public func progressiveSearch(
        query: String,
        options: SKSearchOptions = SKSearchOptions(kSKSearchOptionDefault)
    ) -> ProgressiveSearch {
        return ProgressiveSearch(options: options, index: self, query: query)
    }

    /// A class for creating and managing a progressive search.
    /// A search starts on creation and can be cancelled at any time.
    public class ProgressiveSearch {
        /// A class representing the results of a search request.
        public class Results {
            /// Create a search result
            ///
            /// - Parameters:
            ///   - moreResultsAvailable: A boolean indicating whether more search results are available
            ///   - results: The partial results for the search request
            public init(moreResultsAvailable: Bool, results: [SearchResult]) {
                self.moreResultsAvailable = moreResultsAvailable
                self.results = results
            }

            /// A boolean indicating whether more search results are available
            public let moreResultsAvailable: Bool

            /// The partial results for the search request
            public let results: [SearchResult]
        }

        private let options: SKSearchOptions
        private let search: SKSearch
        private let index: SearchIndexer
        private let query: String

        init(options: SKSearchOptions, index: SearchIndexer, query: String) {
            self.options = options
            self.search = SKSearchCreate(index.index, query as CFString, options).takeRetainedValue()
            self.index = index
            self.query = query
        }

        /// Retrieves the next chunk of search results in a progressive search.
        ///
        /// - Parameters:
        ///   - limit: The maximum number of results to retrieve in each call. Defaults to 10.
        ///   - timeout: The duration to wait for the search to complete before stopping. Defaults to 1.0 seconds.
        ///
        /// - Returns: A tuple containing search results and information about the progress of the search.
        ///
        /// The function performs a progressive search,
        /// fetching the next set of results based on the specified limit and timeout.
        /// It uses the Search Kit framework to find matches, retrieve document URLs, and their corresponding scores.
        public func getNextSearchResultsChunk(
            limit: Int = 10,
            timeout: TimeInterval = 1.0
        ) -> (ProgressiveSearch.Results) {
            guard self.index.index != nil else {
                return Results(moreResultsAvailable: false, results: [])
            }

            var scores: [Float] = Array(repeating: 0.0, count: limit)
            var urls: [Unmanaged<CFURL>?] = Array(repeating: nil, count: limit)
            var documentIDs: [SKDocumentID] = Array(repeating: 0, count: limit)
            var foundCount = 0

            let hasMore = SKSearchFindMatches(self.search, limit, &documentIDs, &scores, timeout, &foundCount)
            SKIndexCopyDocumentURLsForDocumentIDs(self.index.index, foundCount, &documentIDs, &urls)

            let partialResult: [SearchResult] = zip(urls[0..<foundCount], scores)
                .compactMap { (cfurl, score) -> SearchResult? in
                    guard let url  = cfurl?.takeRetainedValue() as URL? else {
                        return nil
                    }

                    return SearchResult(url: url, score: score)
                }

            return Results(moreResultsAvailable: hasMore, results: partialResult)
        }

        /// Cancel an active search
        public func cancel() {
            SKSearchCancel(self.search)
        }
    }
}
