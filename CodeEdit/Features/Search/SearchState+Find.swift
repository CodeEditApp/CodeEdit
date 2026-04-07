//
//  SearchState+Find.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 02.01.24.
//

import Foundation

extension SearchState: @unchecked Sendable {}

extension SearchState {
    /// Searches the entire workspace for the given string, using the
    /// ``Workspace/SearchState-swift.class/selectedMode`` modifiers
    /// to modify the search if needed. This is done by filtering out files with SearchKit and then searching
    /// within each file for the given string.
    ///
    /// This method will update
    /// ``Workspace/SearchState-swift.class/searchResult``,
    /// ``Workspace/SearchState-swift.class/searchResultsFileCount``
    /// and ``Workspace/SearchState-swift.class/searchResultCount`` with any matched
    /// search results. See ``SearchResultModel`` and ``SearchResultMatchModel``
    /// for more information on search results and matches.
    ///
    /// - Parameter query: The search query to search for.
    func search(_ query: String) async {
        clearResults()

        await MainActor.run {
            self.searchQuery = query
            self.findNavigatorStatus = .searching
        }

        let searchQuery = getSearchTerm(query)
        let regexPattern = getRegexPattern(query)

        guard let indexer = indexer else {
            await setStatus(.failed(errorMessage: "No index found. Try rebuilding the index."))
            return
        }

        let asyncController = SearchIndexer.AsyncManager(index: indexer)
        let evaluateResultGroup = DispatchGroup()
        let evaluateSearchQueue = DispatchQueue(label: "app.codeedit.CodeEdit.EvaluateSearch")

        let searchStream = await asyncController.search(query: searchQuery, 20)
        for try await result in searchStream {
            for file in result.results {
                let fileURL = file.url
                let fileScore = file.score
                let capturedRegexPattern = regexPattern

                evaluateSearchQueue.async(group: evaluateResultGroup) {
                    evaluateResultGroup.enter()
                    Task { [weak self] in
                        guard let self else {
                            evaluateResultGroup.leave()
                            return
                        }

                        let result = await self.evaluateSearchResult(
                            fileURL: fileURL,
                            fileScore: fileScore,
                            regexPattern: capturedRegexPattern
                        )

                        if let result = result {
                            await self.appendNewResultsToTempResults(newResult: result)
                        }
                        evaluateResultGroup.leave()
                    }
                }
            }
        }

        evaluateResultGroup.notify(queue: evaluateSearchQueue) {
            Task { @MainActor [weak self] in
                self?.setSearchResults()
            }
        }
    }

    /// Appends a new search result to the temporary search results array on the main thread.
    ///
    /// - Parameters:
    ///   - newResult: The `SearchResultModel` to be appended to the temporary search results.
    @MainActor
    func appendNewResultsToTempResults(newResult: SearchResultModel) {
        self.tempSearchResults.append(newResult)
    }

    /// Sets the search results by updating various properties on the main thread.
    /// This function updates `findNavigatorStatus`, `searchResult`, `searchResultCount`, and `searchResultsFileCount`
    /// and sets the `tempSearchResults` to an empty array.
    /// - Important: Call this function when you are ready to
    /// display or use the final search results.
    @MainActor
    func setSearchResults() {
        self.searchResult = self.tempSearchResults.sorted { $0.score > $1.score }
        self.searchResultsCount = self.tempSearchResults.map { $0.lineMatches.count }.reduce(0, +)
        self.searchResultsFileCount = self.tempSearchResults.count
        self.findNavigatorStatus = .found
        self.tempSearchResults = []
    }

    /// Resets the search results along with counts for overall results and file-specific results.
    func clearResults() {
        DispatchQueue.main.async {
            self.searchResult.removeAll()
            self.searchResultsCount = 0
            self.searchResultsFileCount = 0
            self.findNavigatorStatus = .none
        }
    }
}
