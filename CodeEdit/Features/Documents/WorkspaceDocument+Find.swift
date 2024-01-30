//
//  WorkspaceDocument+Find.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 02.01.24.
//

import Foundation

extension WorkspaceDocument.SearchState {
    /// Creates a search term based on the given query and search mode.
    ///
    /// - Parameter query: The original user query string.
    ///
    /// - Returns: A modified search term according to the specified search mode.
    func getSearchTerm(_ query: String) -> String {
        let newQuery = caseSensitive ? query : query.lowercased()
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

    /// Generates a regular expression pattern based on the specified query and search mode.
    ///
    /// - Parameter query: The original user query string.
    ///
    /// - Returns: A string representing the regular expression pattern based on the selected search mode.
    ///
    /// - Note: This function is creating similar patterns to the
    /// ``WorkspaceDocument/SearchState-swift.class/getSearchTerm(_:)`` function,
    /// Except its using the word boundary anchor(\b) instead of the asterisk(\*).
    /// This is needed to highlight the search results correctly.
    func getRegexPattern(_ query: String) -> String {
        guard let mode = selectedMode.third else {
            return query
        }

        switch mode {
        case .Containing:
            return "\(query)"
        case .StartingWith:
            return "\\b\(query)"
        case .EndingWith:
            return "\(query)\\b"
        case .MatchingWord:
            return "\\b\(query)\\b"
        default:
            return query
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
        clearResults()

        await MainActor.run {
            self.searchQuery = query
            self.findNavigatorStatus = .searching
        }

        let searchQuery = getSearchTerm(query)

        // The regexPattern is only used for the evaluateFile function
        // to ensure that the search terms are highlighted correctly
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
                evaluateSearchQueue.async(group: evaluateResultGroup) {
                    evaluateResultGroup.enter()
                    Task {
                        var newResult = SearchResultModel(file: CEWorkspaceFile(url: file.url), score: file.score)
                        await self.evaluateFile(query: regexPattern, searchResult: &newResult)

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
    /// This function updates `findNavigatorStatus`, `searchResult`, `searchResultCount`, and `searchResultsFileCount`
    /// and sets the `tempSearchResults` to an empty array.
    /// - Important: Call this function when you are ready to
    /// display or use the final search results.
    func setSearchResults() {
        DispatchQueue.main.async {
            self.searchResult = self.tempSearchResults.sorted { $0.score > $1.score }
            self.searchResultsCount = self.tempSearchResults.map { $0.lineMatches.count }.reduce(0, +)
            self.searchResultsFileCount = self.tempSearchResults.count
            self.findNavigatorStatus = .found
            self.tempSearchResults = []
        }
    }

    /// Evaluates a search query within the content of a file and updates
    /// the provided `SearchResultModel` with matching occurrences.
    ///
    /// - Parameters:
    ///   - query: The search query to be evaluated, potentially containing a regular expression.
    ///   - searchResult: The `SearchResultModel` object to be updated with the matching occurrences.
    ///
    /// This function retrieves the content of a file specified in the `searchResult` parameter
    /// and applies a search query using a regular expression.
    /// It then iterates over the matches found in the file content,
    /// creating `SearchResultMatchModel` instances for each match.
    /// The resulting matches are appended to the `lineMatches` property of the `searchResult`.
    /// Line matches are the preview lines that are shown in the search results.
    ///
    /// # Example Usage
    /// ```swift
    /// var resultModel = SearchResultModel()
    /// await evaluateFile(query: "example", searchResult: &resultModel)
    /// ```
    private func evaluateFile(query: String, searchResult: inout SearchResultModel) async {
        guard let data = try? Data(contentsOf: searchResult.file.url),
              let fileContent = String(data: data, encoding: .utf8) else {
            return
        }

        // Attempt to create a regular expression from the provided query
        guard let regex = try? NSRegularExpression(
            pattern: query,
            options: caseSensitive ? [] : [.caseInsensitive]
        ) else {
            await setStatus(.failed(errorMessage: "Invalid regular expression."))
            return
        }

        // Find all matches of the query within the file content using the regular expression
        let matches = regex.matches(in: fileContent, range: NSRange(location: 0, length: fileContent.utf16.count))

        var newMatches = [SearchResultMatchModel]()

        // Process each match and add it to the array of `newMatches`
        for match in matches {
            if let matchRange = Range(match.range, in: fileContent) {
                let matchWordLength = match.range.length
                let matchModel = createMatchModel(
                    from: matchRange,
                    fileContent: fileContent,
                    file: searchResult.file,
                    matchWordLength: matchWordLength
                )
                newMatches.append(matchModel)
            }
        }

        searchResult.lineMatches = newMatches
    }

    /// Creates a `SearchResultMatchModel` instance based on the provided parameters,
    /// representing a matching occurrence within a file.
    ///
    /// - Parameters:
    ///   - matchRange: The range of the matched substring within the entire file content.
    ///   - fileContent: The content of the file where the match was found.
    ///   - file: The `CEWorkspaceFile` object representing the file containing the match.
    ///   - matchWordLength: The length of the matched substring.
    ///
    /// - Returns: A `SearchResultMatchModel` instance representing the matching occurrence.
    ///
    /// This function is responsible for constructing a `SearchResultMatchModel`
    /// based on the provided parameters. It extracts the relevant portions of the file content,
    /// including the lines before and after the match, and combines them into a final line.
    /// The resulting model includes information about the match's range within the file,
    /// the file itself, the content of the line containing the match,
    /// and the range of the matched keyword within that line.
    private func createMatchModel(
        from matchRange: Range<String.Index>,
        fileContent: String,
        file: CEWorkspaceFile,
        matchWordLength: Int
    ) -> SearchResultMatchModel {
        let preLine = extractPreLine(from: matchRange, fileContent: fileContent)
        let keywordRange = extractKeywordRange(from: preLine, matchWordLength: matchWordLength)
        let postLine = extractPostLine(from: matchRange, fileContent: fileContent)

        let finalLine = preLine + postLine

        return SearchResultMatchModel(
            rangeWithinFile: matchRange,
            file: file,
            lineContent: finalLine,
            keywordRange: keywordRange
        )
    }

    /// Extracts the line preceding a matching occurrence within a file.
    ///
    /// - Parameters:
    ///   - matchRange: The range of the matched substring within the entire file content.
    ///   - fileContent: The content of the file where the match was found.
    ///
    /// - Returns: A string representing the line preceding the match.
    ///
    /// This function retrieves the line preceding a matching occurrence within the provided file content.
    /// It considers a context of up to 60 characters before the match and clips the result to the last
    /// occurrence of a newline character, ensuring that only the line containing the search term is displayed.
    /// The extracted line is then trimmed of leading and trailing whitespaces and
    /// newline characters before being returned.
    private func extractPreLine(from matchRange: Range<String.Index>, fileContent: String) -> String {
        let preRangeStart = fileContent.index(
            matchRange.lowerBound,
            offsetBy: -60,
            limitedBy: fileContent.startIndex
        ) ?? fileContent.startIndex

        let preRangeEnd = matchRange.upperBound
        let preRange = preRangeStart..<preRangeEnd

        let preLineWithNewLines = fileContent[preRange]
        // Clip the range of the preview to the last occurrence of a new line
        let lastNewLineIndexInPreLine = preLineWithNewLines.lastIndex(of: "\n") ?? preLineWithNewLines.startIndex
        let preLineWithNewLinesPrefix = preLineWithNewLines[lastNewLineIndexInPreLine...]

        return preLineWithNewLinesPrefix.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Extracts the range of the search term within the line preceding a matching occurrence.
    ///
    /// - Parameters:
    ///   - preLine: The line preceding the matching occurrence within the file content.
    ///   - matchWordLength: The length of the search term.
    ///
    /// - Returns: A range representing the position of the search term within the `preLine`.
    ///
    /// This function calculates the range of the search term within
    /// the provided line preceding a matching occurrence.
    /// It considers the length of the search term to determine
    /// the lower and upper bounds of the keyword range within the line.
    private func extractKeywordRange(from preLine: String, matchWordLength: Int) -> Range<String.Index> {
        let keywordLowerBound = preLine.index(
            preLine.endIndex,
            offsetBy: -matchWordLength,
            limitedBy: preLine.startIndex
        ) ?? preLine.endIndex
        let keywordUpperBound = preLine.endIndex

        return keywordLowerBound..<keywordUpperBound
    }

    /// Extracts the line following a matching occurrence within a file.
    ///
    /// - Parameters:
    ///   - matchRange: The range of the matched substring within the entire file content.
    ///   - fileContent: The content of the file where the match was found.
    ///
    /// - Returns: A string representing the line following the match.
    ///
    /// This function retrieves the line following a matching occurrence within the provided file content.
    /// It considers a context of up to 60 characters after the match and clips the result to the first
    /// occurrence of a newline character, ensuring that only the relevant portion of the line is displayed.
    /// The extracted line is then converted to a string before being returned.
    private func extractPostLine(from matchRange: Range<String.Index>, fileContent: String) -> String {
        let postRangeStart = matchRange.upperBound
        let postRangeEnd = fileContent.index(
            matchRange.upperBound,
            offsetBy: 60,
            limitedBy: fileContent.endIndex
        ) ?? fileContent.endIndex

        let postRange = postRangeStart..<postRangeEnd
        let postLineWithNewLines = fileContent[postRange]

        let firstNewLineIndexInPostLine = postLineWithNewLines.firstIndex(of: "\n") ?? postLineWithNewLines.endIndex
        return String(postLineWithNewLines[..<firstNewLineIndexInPostLine])
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
