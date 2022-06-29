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
        @Published var searchResult: [SearchResultModel] = []

        var ignoreCase: Bool = true

        init(_ workspace: WorkspaceDocument) {
            self.workspace = workspace
        }

        func search(_ text: String) {
            let textToCompare = ignoreCase ? text.lowercased() : text
            self.searchResult = []
            if let url = self.workspace.fileURL {
                let enumerator = FileManager.default.enumerator(at: url,
                                                                includingPropertiesForKeys: [
                                                                    .isRegularFileKey
                                                                ],
                                                                options: [
                                                                    .skipsHiddenFiles,
                                                                    .skipsPackageDescendants
                                                                ])
                if let filePaths = enumerator?.allObjects as? [URL] {
                    filePaths.map { url in
                        WorkspaceClient.FileItem(url: url, children: nil)
                    }.forEach { fileItem in
                        var fileAddedFlag = true
                        do {
                            let data = try Data(contentsOf: fileItem.url)
                            data.withUnsafeBytes {
                                $0.split(separator: UInt8(ascii: "\n"))
                                    .map { String(decoding: UnsafeRawBufferPointer(rebasing: $0), as: UTF8.self) }
                            }.enumerated().forEach { (index: Int, line: String) in
                                let rawNoSpaceLine = line.trimmingCharacters(in: .whitespaces)
                                let noSpaceLine = ignoreCase ? rawNoSpaceLine.lowercased() : rawNoSpaceLine
                                if noSpaceLine.contains(textToCompare) {
                                    Swift.print(noSpaceLine)
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
                        } catch {}
                    }
                }
            }
        }
    }
}
