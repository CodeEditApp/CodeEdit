//
//  WorkspaceDocument+Search.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 30.04.22.
//

import Foundation

extension WorkspaceDocument {
    final class SearchState: ObservableObject {
        @Published var searchResult: [SearchResultModel] = []
        @Published var searchResultsFileCount: Int = 0
        @Published var searchResultsCount: Int = 0

        unowned var workspace: WorkspaceDocument
        var tempSearchResults = [SearchResultModel]()
        var ignoreCase: Bool = true
        var indexer: SearchIndexer?
        var selectedMode: [SearchModeModel] = [
            .Find,
            .Text,
            .Containing
        ]

        init(_ workspace: WorkspaceDocument) {
            self.workspace = workspace
            self.indexer = SearchIndexer.Memory.create()
            addProjectToIndex()
        }

        /// Adds the contents of the current worksapce URL to the search index.
        /// That means that the contents of the workspace will be indexed and searchable.
        func addProjectToIndex() {
            guard let indexer = indexer else {
                return
            }

            guard let url = workspace.fileURL else {
                return
            }

            let filePaths = getFileURLs(at: url)
            Task {
                let textFiles = await getfileContent(from: filePaths)
                let asyncController = SearchIndexer.AsyncManager(index: indexer)
                _ = await asyncController.addText(files: textFiles, flushWhenComplete: true)
            }
        }

        /// Retrieves an array of file URLs within the specified directory URL.
        ///
        /// - Parameter url: The URL of the directory to search for files.
        ///
        /// - Returns: An array of file URLs found within the specified directory.
        func getFileURLs(at url: URL) -> [URL] {
            let enumerator = FileManager.default.enumerator(
                at: url,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            )
            return enumerator?.allObjects as? [URL] ?? []
        }

        /// Retrieves the contents of a files  from the specified file paths.
        ///
        /// - Parameter filePaths: An array of file URLs representing the paths of the files.
        ///
        /// - Returns: An array of `TextFile` objects containing the standardized file URLs and text content.
        func getfileContent(from filePaths: [URL]) async -> [SearchIndexer.AsyncManager.TextFile] {
            var textFiles = [SearchIndexer.AsyncManager.TextFile]()
            for file in filePaths {
                if let content = try? String(contentsOf: file) {
                    textFiles.append(
                        SearchIndexer.AsyncManager.TextFile(url: file.standardizedFileURL, text: content)
                    )
                }
            }
            return textFiles
        }

        /// Creates a search term based on the given query and search mode.
        ///
        /// - Parameter query: The original user query string.
        ///
        /// - Returns: A modified search term according to the specified search mode.
        func getSearchTerm(_ query: String) -> String {
            let newQuery = ignoreCase ? query.lowercased() : query
            guard let mode = selectedMode.third else {
                return newQuery
            }
            switch mode {
            case .Containing:
                return "*\(newQuery)*"
            case .StartingWith:
                return "\(newQuery)*"
            case .EndingWith:
                return "*\(newQuery)"
            default:
                return newQuery
            }
        }

        /// Searches the entire workspace for the given string, using the
        /// ``WorkspaceDocument/SearchState-swift.class/selectedMode`` modifiers
        /// to modify the search if needed. This is done by filtering out files with SearchKit and then searching
        /// within each file for the given string.
        ///
        /// This method will update
        /// ``WorkspaceDocument/SearchState-swift.class/searchResult``,
        /// ``WorkspaceDocument/SearchState-swift.class/searchResultsFileCount``
        /// and ``WorkspaceDocument/SearchState-swift.class/searchResultCount`` with any matched
        /// search results. See ``SearchResultModel`` and ``SearchResultMatchModel``
        /// for more information on search results and matches.
        ///
        /// - Parameter query: The search query to search for.
        func search(_ query: String) async {
            let searchQuery = getSearchTerm(query)
            guard let indexer = indexer else {
                return
            }

            let asyncController = SearchIndexer.AsyncManager(index: indexer)

            let evaluateResultGroup = DispatchGroup()
            let evaluateSearchQueue = DispatchQueue(label: "app.codeedit.CodeEdit.EvaluateSearch")

            let searchStream = await asyncController.search(query: searchQuery, 20)
            for try await result in searchStream {
                let urls: [(URL, Float)] = result.results.map {
                    ($0.url, $0.score)
                }

                for (url, score) in urls {
                    evaluateSearchQueue.async(group: evaluateResultGroup) {
                        evaluateResultGroup.enter()
                        Task {
                            var newResult = SearchResultModel(file: CEWorkspaceFile(url: url), score: score)
                            await self.evaluateFile(query: query.lowercased(), searchResult: &newResult)

                            // Check if the new result has any line matches.
                            if !newResult.lineMatches.isEmpty {
                                // The function needs to be called because,
                                // we are trying to modify the array from within a concurrent context.
                                self.appendNewResultsToTempResults(newResult: newResult)
                            }
                            evaluateResultGroup.leave()
                        }
                    }
                }
            }

            evaluateResultGroup.notify(queue: evaluateSearchQueue) {
                self.setSearchResults()
            }
        }

        /// Appends a new search result to the temporary search results array on the main thread.
        ///
        /// - Parameters:
        ///   - newResult: The `SearchResultModel` to be appended to the temporary search results.
        func appendNewResultsToTempResults(newResult: SearchResultModel) {
            DispatchQueue.main.async {
                self.tempSearchResults.append(newResult)
            }
        }

        /// Sets the search results by updating various properties on the main thread.
        /// This function updates `searchResult`, `searchResultCount`, and `searchResultsFileCount`
        /// and sets the `tempSearchResults` to an empty array.
        /// - Important: Call this function when you are ready to
        /// display or use the final search results.
        func setSearchResults() {
            DispatchQueue.main.async {
                self.searchResult = self.tempSearchResults.sorted { $0.score > $1.score }
                self.searchResultsCount = self.tempSearchResults.map { $0.lineMatches.count }.reduce(0, +)
                self.searchResultsFileCount = self.tempSearchResults.count
                self.tempSearchResults = []
            }
        }

        /// Addes line matchings to a `SearchResultsViewModel` array.
        /// That means if a search result is a file, and the search term appears in the file,
        /// the function will add the line number, line content, and keyword range to the `SearchResultsViewModel`.
        ///
        /// - Parameters:
        ///   - query: The search query string.
        ///   - searchResults: An inout parameter containing the array of `SearchResultsViewModel` to be evaluated.
        ///   It will be modified to include line matches.
        private func evaluateFile(query: String, searchResult: inout SearchResultModel) async {
            var newMatches = [SearchResultMatchModel]()

            guard let data = try? Data(contentsOf: searchResult.file.url),
                  let fileContent = String(data: data, encoding: .utf8) else {
                return
            }

            // Attempt to create a regular expression from the provided query
            guard let regex = try? NSRegularExpression(pattern: query, options: [.caseInsensitive]) else {
                return
            }

            // Find all matches of the query within the file content using the regular expression
            let matches = regex.matches(in: fileContent, range: NSRange(location: 0, length: fileContent.utf16.count))

            // Process each match and add it to the array of `newMatches`
            for match in matches {
                if let matchRange = Range(match.range, in: fileContent) {
                    // Extract the length of the entire match, i.e., the part that appears in bold
                    let matchWordLenght = match.range.length

                    // MARK: - Pre Range
                    // Extract the range before the result, including the search term
                    let preRangeStart = fileContent.index(
                        matchRange.lowerBound,
                        offsetBy: -60,
                        limitedBy: fileContent.startIndex
                    ) ?? fileContent.startIndex // TODO: Better error handling
                    let preRangeEnd = matchRange.upperBound
                    let preRange = preRangeStart..<preRangeEnd

                    // Clip the range of the preview to the last occurrence of a new line,
                    // displaying only the line in which the search term appears
                    let preLineWithNewLines = fileContent[preRange]
                    let lastNewLineIndexInPreLine = preLineWithNewLines
                        .lastIndex(of: "\n") ?? preLineWithNewLines.startIndex
                    let preLineWithNewLinesPrefix = preLineWithNewLines[lastNewLineIndexInPreLine...]
                    let preLine = preLineWithNewLinesPrefix
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    // Convert SubString to String, necessary for the next step
                    let preLineString = String(preLine)

                    // Get the range of the search term within the pre line
                    let keywordLowerbound = preLineString.index(
                        preLineString.endIndex,
                        offsetBy: -matchWordLenght,
                        limitedBy: preLineString.startIndex
                    ) ?? preLineString.endIndex
                    let keywordUpperbound = preLineString.endIndex
                    let keywordRange = keywordLowerbound..<keywordUpperbound

                    // MARK: - Post Range
                    // Extract the range after the search term, limiting to 60 characters
                    let postRangeStart = matchRange.upperBound
                    let postRangeEnd = fileContent.index(
                        matchRange.upperBound,
                        offsetBy: 60,
                        limitedBy: fileContent.endIndex
                    ) ?? fileContent.endIndex // TODO: Better error handling
                    let postRange = postRangeStart..<postRangeEnd
                    let postLineWithNewLines = fileContent[postRange]

                    // Clip the range to the first occurrence of a new line
                    let firstNewLineIndexInPostLine = postLineWithNewLines
                        .firstIndex(of: "\n") ?? postLineWithNewLines.endIndex
                    let postLine = postLineWithNewLines[..<firstNewLineIndexInPostLine]
                    let postLineString = String(postLine)

                    // Join the pre and post range to get the final line
                    // The search term stays at the same range because
                    // it is included in the `postLineString`
                    let finalLine = preLineString + postLineString

                    // Create a SearchResultMatchModel and append it to the list of new matches
                    let matchModel = SearchResultMatchModel(
                        rangeWithinFile: matchRange,
                        file: searchResult.file,
                        lineContent: finalLine,
                        keywordRange: keywordRange
                    )
                    newMatches.append(matchModel)
                }
            }

            // Update the search result model with the new matches
            searchResult.lineMatches = newMatches
        }

        /// Resets the search results along with counts for overall results and file-specific results.
        func clearResults() {
            DispatchQueue.main.async {
                self.searchResult.removeAll()
                self.searchResultsCount = 0
                self.searchResultsFileCount = 0
            }
        }
    }
}

extension StringProtocol {
    var lines: [SubSequence] { split(whereSeparator: \.isNewline) }
    var removingAllExtraNewLines: String { lines.joined(separator: "\n") }
}
