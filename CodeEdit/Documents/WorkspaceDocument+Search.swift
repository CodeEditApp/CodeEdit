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

            filePaths.map { url in
                WorkspaceClient.FileItem(url: url, children: nil)
            }.forEach { fileItem in
                var fileAddedFlag = true
                guard let data = try? Data(contentsOf: fileItem.url) else { return }

                data.withUnsafeBytes {
                    $0.split(separator: UInt8(ascii: "\n"))
                        .map { String(decoding: UnsafeRawBufferPointer(rebasing: $0), as: UTF8.self) }
                }.enumerated().forEach { (index: Int, line: String) in
                    let rawNoSpaceLine = line.trimmingCharacters(in: .whitespaces)
                    let noSpaceLine = ignoreCase ? rawNoSpaceLine.lowercased() : rawNoSpaceLine
                    if lineContainsSearchTerm(line: noSpaceLine, term: textToCompare) {
                        if fileAddedFlag {
                            searchResult.append(SearchResultModel(
                                file: fileItem,
                                lineNumber: nil,
                                lineContent: nil,
                                keywordRange: nil)
                            )
                            fileAddedFlag = false
                        }
                        noSpaceLine.ranges(of: textToCompare).forEach { range in
                            searchResult.append(SearchResultModel(
                                file: fileItem,
                                lineNumber: index,
                                lineContent: rawNoSpaceLine,
                                keywordRange: range)
                            )
                        }
                    }
                }
            }
        }

        // see if the line contains search term, obeying selectedMode
        func lineContainsSearchTerm(line rawLine: String, term searchterm: String) -> Bool {
            var line = rawLine
            if line.hasSuffix(" ") { line.removeLast() }
            if line.hasPrefix(" ") { line.removeFirst() }

            // Text
            let findMode = selectedMode[1]
            if findMode == .Text {
                let textMatching = selectedMode[2]
                guard textMatching != .Containing else {
                    return line.contains(searchterm)
                }
                var foundMatch = false
                switch textMatching {
                case .MatchingWord:
                    foundMatch = " \(line) ".contains(" \(searchterm) ")
                case .StartingWith:
                    foundMatch = " \(line)".contains(" \(searchterm)")
                case .EndingWith:
                    foundMatch = "\(line) ".contains("\(searchterm) ")
                default: return false
                }
                return foundMatch
            } else if findMode == .RegularExpression {
                guard let regex = try? NSRegularExpression(pattern: searchterm) else { return false }
                // swiftlint:disable legacy_constructor
                return regex.firstMatch(in: line, range: NSMakeRange(0, line.utf16.count)) != nil
            }

            return false

            // TODO: references and definitions
        }
    }
}
