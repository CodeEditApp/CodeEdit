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
        @Published var searchResultCount: Int = 0

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
                // Handle error
                return
            }

            guard let url = workspace.fileURL else {
                // Handle error
                return
            }

            let filePaths = getFileURLs(at: url)
            Task {
                let textFiles = await getFileContents(from: filePaths)
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
        func getFileContents(from filePaths: [URL]) async -> [SearchIndexer.AsyncManager.TextFile] {
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
            let startTime = Date()
            let searchQuery = getSearchTerm(query)
            guard let indexer = indexer else {
                return
            }

            let asyncController = SearchIndexer.AsyncManager(index: indexer)

            let evaluateResultGroup = DispatchGroup()
            let evaluateSearchQueue = DispatchQueue(label: "search")

            let searchStream = await asyncController.search(query: searchQuery, 20)
            for try await result in searchStream {
                let urls2: [(URL, Float)] = result.results.map {
                    ($0.url, $0.score)
                }

                for (url, score) in urls2 {
                    evaluateSearchQueue.async(group: evaluateResultGroup) {
                        evaluateResultGroup.enter()
                        Task {
                            var newResult = SearchResultModel(file: CEWorkspaceFile(url: url), score: score)
                            await self.evaluateResult(query: query.lowercased(), searchResult: &newResult)

                            // The funciton needs to be called because,
                            // we are trying to modify the array from within a concurrent context.
                            self.appendNewResultsToTempResults(newResult: newResult)
                            evaluateResultGroup.leave()
                        }
                    }
                }
            }

            evaluateResultGroup.notify(queue: evaluateSearchQueue) {
                    self.setSearchResults()
//                    fatalError("\(Date().timeIntervalSince(startTime))")
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
                self.searchResultCount = self.tempSearchResults.map { $0.lineMatches.count }.reduce(0, +)
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
        private func evaluateResult(query: String, searchResult: inout SearchResultModel) async {
            let searchResultCopy = searchResult
            var newMatches = [SearchResultMatchModel]()

            guard let data = try? Data(contentsOf: searchResult.file.url),
                  let string = String(data: data, encoding: .utf8) else {
                return
            }

            await withTaskGroup(of: SearchResultMatchModel?.self) { group in
                for (lineNumber, line) in string.split(separator: "\n").lazy.enumerated() {
                    group.addTask {
                        let rawNoSapceLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                        let noSpaceLine = rawNoSapceLine.lowercased()
                        if self.lineContainsSearchTerm(line: noSpaceLine, term: query) {
                            let matches = noSpaceLine.ranges(of: query).map { range in
                                return [lineNumber, noSpaceLine, range]
                            }

                            for match in matches {
                                if let lineNumber = match[0] as? Int,
                                   let lineContent = match[1] as? String,
                                   let keywordRange = match[2] as? Range<String.Index> {
                                    let matchModel = SearchResultMatchModel(
                                        lineNumber: lineNumber,
                                        file: searchResultCopy.file,
                                        lineContent: lineContent,
                                        keywordRange: keywordRange
                                    )

                                    return matchModel
                                } else {
                                    fatalError("Failed to parse match model")
                                }
                            }
                        }
                        return nil
                    }
                    for await groupRes in group {
                        if let groupRes {
                            newMatches.append(groupRes)
                        }
                    }
                }
            }
            searchResult.lineMatches = newMatches
        }

        // see if the line contains search term, obeying selectedMode
        // swiftlint:disable:next cyclomatic_complexity
        func lineContainsSearchTerm(line rawLine: String, term searchterm: String) -> Bool {
            var line = rawLine
            if line.hasSuffix(" ") { line.removeLast() }
            if line.hasPrefix(" ") { line.removeFirst() }

            // Text
            let findMode = selectedMode[1]
            if findMode == .Text {
                let textMatching = selectedMode[2]
                let textContainsSearchTerm = line.contains(searchterm)
                guard textContainsSearchTerm == true else { return false }
                guard textMatching != .Containing else { return textContainsSearchTerm }

                // get the index of the search term's appearance in the line
                // and get the characters to the left and right
                let appearances = line.appearancesOfSubstring(substring: searchterm, toLeft: 1, toRight: 1)
                var foundMatch = false
                for appearance in appearances {
                    let appearanceString = String(line[appearance])
                    guard appearanceString.count >= 2 else { continue }

                    var startsWith = false
                    var endsWith = false
                    if appearanceString.hasPrefix(searchterm) ||
                        !appearanceString.first!.isLetter ||
                        !appearanceString.character(at: 2).isLetter {
                        startsWith = true
                    }
                    if appearanceString.hasSuffix(searchterm) ||
                        !appearanceString.last!.isLetter ||
                        !appearanceString.character(at: appearanceString.count-2).isLetter {
                        endsWith = true
                    }

                    switch textMatching {
                    case .MatchingWord:
                        foundMatch = startsWith && endsWith ? true : foundMatch
                    case .StartingWith:
                        foundMatch = startsWith ? true : foundMatch
                    case .EndingWith:
                        foundMatch = endsWith ? true : foundMatch
                    default: continue
                    }
                }
                return foundMatch
            } else if findMode == .RegularExpression {
                guard let regex = try? NSRegularExpression(pattern: searchterm) else { return false }
                // swiftlint:disable:next legacy_constructor
                return regex.firstMatch(in: String(line), range: NSMakeRange(0, line.utf16.count)) != nil
            }

            return false
            // TODO: references and definitions
        }
    }
}

extension String {
    /// Retrieves the character at the specified index within the string.
    /// - Parameter index: The index of the character to retrieve.
    /// - Returns: The character at the specified index.
    func character(at index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }

    /// Finds the appearances of a substring within the string.
    /// - Parameters:
    ///   - substring: The substring to search for within the string.
    ///   - toLeft: The optional number of characters to include to the left of each found substring appearance.
    ///   - toRight: The optional number of characters to include to the right of each found substring appearance.
    ///
    ///   - Returns: An array of ranges representing the appearances of the substring within the string.
    func appearancesOfSubstring(substring: String, toLeft: Int=0, toRight: Int=0) -> [Range<String.Index>] {
        guard !substring.isEmpty && self.contains(substring) else { return [] }
        var appearances: [Range<String.Index>] = []
        for (index, character) in self.enumerated() where character == substring.first {
            let startOfFoundCharacter = self.index(self.startIndex, offsetBy: index)
            guard index + substring.count < self.count else { continue }
            let lengthOfFoundCharacter = self.index(self.startIndex, offsetBy: (substring.count + index))
            if self[startOfFoundCharacter..<lengthOfFoundCharacter] == substring {
                let startIndex = self.index(
                    self.startIndex,
                    offsetBy: index - (toLeft <= index ? toLeft : 0)
                )
                let endIndex = self.index(
                    self.startIndex,
                    offsetBy: substring.count + index + (substring.count+index+toRight <= self.count ? toRight : 0)
                )
                appearances.append(startIndex..<endIndex)
            }
        }
        return appearances
    }
}
