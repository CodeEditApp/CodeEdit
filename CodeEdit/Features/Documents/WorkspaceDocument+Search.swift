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

        func addProjectToIndex() {
            guard let indexer = indexer else {
                return
            }

            guard let url = self.workspace.fileURL else { return }
            let enumerator = FileManager.default.enumerator(
                at: url,
                includingPropertiesForKeys: [
                    .isRegularFileKey
                ],
                options: [
                    .skipsHiddenFiles,
                    .skipsPackageDescendants
                ]
            )
            guard let filePaths = enumerator?.allObjects as? [URL] else { return }

            let asyncController = SearchIndexer.AsyncManager(index: indexer)

            Task {
                var textFiles = [SearchIndexer.AsyncManager.TextFile]()

                for file in filePaths {
                    if let content = try? String(contentsOf: file) {
                        textFiles.append(
                            SearchIndexer.AsyncManager.TextFile(url: file.standardizedFileURL, text: content)
                        )
                    }
                }

                _ = await asyncController.addText(files: textFiles, flushWhenComplete: true)
            }
        }

        func getSearchTerm(_ query: String) -> String {
            let newQuery = ignoreCase ? query.lowercased() : query
            if selectedMode.third == .Containing {
                return "*\(newQuery)*"
            } else if selectedMode.third == .StartingWith {
                return "\(newQuery)*"
            } else if selectedMode.third == .EndingWith {
                return "*\(newQuery)"
            } else {
                return newQuery
            }
        }

        let appendQueue = DispatchQueue(label: "append")
        var tempSearchResults = [SearchResultModel]()

        // TODO: Wirte proper documentation
        /// Searches the entire workspace for the given string, using the
        /// ``WorkspaceDocument/SearchState-swift.class/selectedMode`` modifiers
        /// to modify the search if needed.
        ///
        /// This method will update
        /// ``WorkspaceDocument/SearchState-swift.class/searchResult``
        /// and ``WorkspaceDocument/SearchState-swift.class/searchResultCount`` with any matched
        /// search results. See `Search.SearchResultModel` and `Search.SearchResultMatchModel`
        /// for more information on search results and matches.
        ///
        /// - Parameter text: The search text to search for. Pass `nil` to this parameter to clear
        ///                   the search results.
        ///
        func searchIndexAsync(_ query: String) async {
            let startTime = Date()
            let searchQuery = getSearchTerm(query)
            guard let indexer = indexer else {
                return
            }

            let asyncController = SearchIndexer.AsyncManager(index: indexer)

            let group = DispatchGroup()
            let queue = DispatchQueue(label: "search")

            let searchStream = await asyncController.search(query: searchQuery, 20)
            for try await result in searchStream {
                let urls = result.results.map {
                    $0.url
                }
                for url in urls {
                    queue.async(group: group) {
                        group.enter()
                        Task {
                            var newResult = SearchResultModel(file: CEWorkspaceFile(url: url))
                            await self.evaluateResult(query: query, searchResult: &newResult)
                            self.tempSearchResults.append(newResult) // this doesn't work due to some error in swift 6
                            group.leave()
                        }
                    }
                }
            }

            group.notify(queue: queue) {
                DispatchQueue.main.async {
                    self.searchResult = self.tempSearchResults
                    self.searchResultCount = self.tempSearchResults.map { $0.lineMatches.count }.reduce(0, +)
                    self.searchResultsFileCount = self.tempSearchResults.count
                    //                                        fatalError("\(Date().timeIntervalSince(startTime))")
                }
            }
        }

        // This could be optimized further by doing a couple things:
        // - Making sure strings and indexes are using UTF8 everywhere possible
        //   (this will increase matching speed and time taken to calculate byte offsets for string indexes)
        // - Lazily fetching file paths. Right now we do `enumerator.allObjects`, but using an actual
        //   enumerator object to lazily enumerate through files would drop time.
        // - Loop through each character instead of each line to find matches, then return the line if needed.
        //   This could help in cases when the file is one *massive* line (eg: a minified JS document).
        // - Lazily load strings using `FileHandle.AsyncBytes`
        //   https://developer.apple.com/documentation/foundation/filehandle/3766681-bytes

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
    func character(at index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }

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
