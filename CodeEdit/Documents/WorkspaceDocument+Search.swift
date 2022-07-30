//
//  WorkspaceDocument+Search.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 30.04.22.
//

import Foundation
import Search
import WorkspaceClient

extension WorkspaceDocument {
    final class SearchState: ObservableObject {
        var workspace: WorkspaceDocument
        var selectedMode: [SearchModeModel] = [
            .Find,
            .Text,
            .Containing
        ]
        @Published var searchResult: [SearchResultModel] = []
        @Published var searchResultCount: Int = 0
        @Published var searchText: String = ""

        var ignoreCase: Bool = true

        init(_ workspace: WorkspaceDocument) {
            self.workspace = workspace
        }

        func search(_ text: String) {
            let textToCompare = ignoreCase ? text.lowercased() : text
            self.searchResult = []
            guard let url = self.workspace.fileURL else { return }
            let enumerator = FileManager.default.enumerator(at: url,
                                                            includingPropertiesForKeys: [
                                                                .isRegularFileKey
                                                            ],
                                                            options: [
                                                                .skipsHiddenFiles,
                                                                .skipsPackageDescendants
                                                            ])
            guard let filePaths = enumerator?.allObjects as? [URL] else { return }

            // TODO: Optimisation
            filePaths.map { url in
                WorkspaceClient.FileItem(url: url, children: nil)
            }.forEach { fileItem in
                guard let data = try? Data(contentsOf: fileItem.url),
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
                            return SearchResultMatchModel(lineNumber: lineNumber,
                                                          file: fileItem,
                                                          lineContent: String(noSpaceLine),
                                                          keywordRange: range)
                        }
                        if fileSearchResult != nil {
                            // We've already found something in this file, add the rest
                            // of the matches
                            fileSearchResult?.lineMatches.append(contentsOf: matches)
                        } else {
                            // We haven't found anything in this file yet, record a new one
                            fileSearchResult = SearchResultModel(file: fileItem,
                                                                 lineMatches: matches)
                        }
                        searchResultCount += 1
                    }
                }

                // If `fileSearchResult` isn't nil it means we've found matches in the file
                // so we add it to the search results.
                if let fileSearchResult = fileSearchResult {
                    searchResult.append(fileSearchResult)
                }
            }
        }

        // see if the line contains search term, obeying selectedMode
        // swiftlint:disable cyclomatic_complexity
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
                // swiftlint:disable legacy_constructor
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
                let startIndex = self.index(self.startIndex,
                    offsetBy: index - (toLeft <= index ? toLeft : 0))
                let endIndex = self.index(self.startIndex,
                    offsetBy: substring.count + index +
                        (substring.count+index+toRight <= self.count ? toRight : 0))
                appearances.append(startIndex..<endIndex)
            }
        }
        return appearances
    }
}
