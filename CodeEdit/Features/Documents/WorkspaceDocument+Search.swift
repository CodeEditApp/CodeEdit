//
//  WorkspaceDocument+Search.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 30.04.22.
//

import Foundation

extension WorkspaceDocument {
    final class SearchState: ObservableObject {
        unowned var workspace: WorkspaceDocument
        var selectedMode: [SearchModeModel] = [
            .Find,
            .Text,
            .Containing
        ]
        @Published var searchResult: [SearchResultModel] = []
        @Published var searchResultCount: Int = 0

        var ignoreCase: Bool = true
        var indexer: SearchIndexer?

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

        func searchIndex(_ query: String) {
            let startTime = Date()
            guard let indexer = indexer else {
                return
            }
            var newSearchResults = [SearchResultModel]()
            let results = indexer.search(query, limit: 20)
            for result in results {
                let newResult = SearchResultModel(file: CEWorkspaceFile(url: result.url))

                newSearchResults.append(newResult)
            }

            evaluateResults(query: query, searchResults: &newSearchResults)

            searchResult = newSearchResults
//            fatalError("\(Date().timeIntervalSince(startTime))")
        }

        /// Addes line matchings to a `SearchResultsViewModel` array.
        /// That means if a search result is a file, and the search term appears in the file,
        /// the function will add the line number, line content, and keyword range to the `SearchResultsViewModel`.
        ///
        /// - Parameters:
        ///   - query: The search query string.
        ///   - searchResults: An inout parameter containing the array of `SearchResultsViewModel` to be evaluated. 
        ///   It will be modified to include line matches.
        private func evaluateResults(query: String, searchResults: inout [SearchResultModel]) {
            searchResults = searchResults.map { result in
                var newResult = result
                var newMatches = [SearchResultMatchModel]()
                guard let data = try? Data(contentsOf: result.file.url), 
                        let string = String(data: data, encoding: .utf8) else {
                    fatalError("Failed to read file: \(result.file.url.absoluteString)")
                    return newResult
                }

                for (lineNumber, line) in string.split(separator: "\n").lazy.enumerated() {
                    let rawNoSapceLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    let noSpaceLine = rawNoSapceLine.lowercased()

                    if lineContainsSearchTerm2(line: noSpaceLine, query: query) {
                        let matches = noSpaceLine.ranges(of: query).map { range in
                            return [lineNumber, noSpaceLine, range]
                        }
                        for match in matches {
                            if let lineNumber = match[0] as? Int,
                               let lineContent = match[1] as? String,
                               let keywordRange = match[2] as? Range<String.Index> {
                                let matchModel = SearchResultMatchModel(lineNumber: lineNumber, file: result.file, lineContent: lineContent, keywordRange: keywordRange)
                                newMatches.append(matchModel)
                            } else {
                                fatalError("Failed to parse match model")
                            }
                        }
                    }
                }
                newMatches.forEach { match in
                    newResult.lineMatches.append(match)
                }
                return newResult
            }
        }

        func lineContainsSearchTerm2(line: String, query: String) -> Bool {
            var line = line
            if line.hasPrefix(" ") { line.removeFirst() }
            if line.hasSuffix(" ") { line.removeLast() }

            let textContainsSearchTerm = line.contains(query)
            guard textContainsSearchTerm else { return false }

            let appearances = line.appearancesOfSubstring(substring: query, toLeft: 1, toRight: 1)
            var foundMatch = false
            for appearance in appearances {
                let appearanceString = String(line[appearance])
                guard appearanceString.count >= 2 else { continue }

                var startsWith = false
                var endsWith = false
                if appearanceString.hasPrefix(query) ||
                    !appearanceString.first!.isLetter ||
                    !appearanceString.character(at: 2).isLetter {
                    startsWith = true
                }
                if appearanceString.hasSuffix(query) ||
                    !appearanceString.last!.isLetter ||
                    !appearanceString.character(at: appearanceString.count-2).isLetter {
                    endsWith = true
                }

                // only matching for now
                return startsWith && endsWith ? true : false

                //            switch textMatching {
                //            case .MatchingWord:
                //                foundMatch = startsWith && endsWith ? true : foundMatch
                //            case .StartingWith:
                //                foundMatch = startsWith ? true : foundMatch
                //            case .EndingWith:
                //                foundMatch = endsWith ? true : foundMatch
                //            default: continue
                //            }
            }

            return false
        }



        /// Searches the entire workspace for the given string, using the ``selectedMode`` modifiers
        /// to modify the search if needed.
        ///
        /// This method will update ``searchResult`` and ``searchResultCount`` with any matched
        /// search results. See `Search.SearchResultModel` and `Search.SearchResultMatchModel`
        /// for more information on search results and matches.
        ///
        /// - Parameter text: The search text to search for. Pass `nil` to this parameter to clear
        ///                   the search results.
        func search(_ text: String?) { // swiftlint:disable:this function_body_length
            guard let text else {
                searchResult = []
                searchResultCount = 0
                return
            }

            let textToCompare = ignoreCase ? text.lowercased() : text
            self.searchResult = []
            self.searchResultCount = 0
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

            // This could be optimized further by doing a couple things:
            // - Making sure strings and indexes are using UTF8 everywhere possible
            //   (this will increase matching speed and time taken to calculate byte offsets for string indexes)
            // - Lazily fetching file paths. Right now we do `enumerator.allObjects`, but using an actual
            //   enumerator object to lazily enumerate through files would drop time.
            // - Loop through each character instead of each line to find matches, then return the line if needed.
            //   This could help in cases when the file is one *massive* line (eg: a minified JS document).
            // - Lazily load strings using `FileHandle.AsyncBytes`
            //   https://developer.apple.com/documentation/foundation/filehandle/3766681-bytes
            filePaths.forEach { url in
                guard let data = try? Data(contentsOf: url),
                      let string = String(data: data, encoding: .utf8) else { return }
                var fileSearchResult: SearchResultModel?

                // Loop through each line and look for any matches
                // If one is found we create a `SearchResultModel` and add any lines
                // with matches, and any information we may need to display or navigate
                // to them.
                for (lineNumber, line) in string.split(separator: "\n").lazy.enumerated() {
                    let rawNoSpaceLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    let noSpaceLine = ignoreCase ? rawNoSpaceLine.lowercased() : rawNoSpaceLine

                    if lineContainsSearchTerm(line: noSpaceLine, term: textToCompare) {
                        // We've got a match
                        let matches = noSpaceLine.ranges(of: textToCompare).map { range in
                            return SearchResultMatchModel(
                                lineNumber: lineNumber,
                                file: CEWorkspaceFile(url: url),
                                lineContent: String(noSpaceLine),
                                keywordRange: range
                            )
                        }
                        if fileSearchResult != nil {
                            // We've already found something in this file, add the rest
                            // of the matches
                            fileSearchResult?.lineMatches.append(contentsOf: matches)
                        } else {
                            // We haven't found anything in this file yet, record a new one
                            fileSearchResult = SearchResultModel(
                                file: CEWorkspaceFile(url: url),
                                lineMatches: matches
                            )
                        }
                        searchResultCount += matches.count
                    }
                }

                // If `fileSearchResult` isn't nil it means we've found matches in the file
                // so we add it to the search results.
                if let fileSearchResult {
                    searchResult.append(fileSearchResult)
                }
            }
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
