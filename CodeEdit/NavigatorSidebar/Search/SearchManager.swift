//
//  SearchManager.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/20.
//

import Foundation
import WorkspaceClient
import Combine

class SearchManager: ObservableObject {
    @Published var searchResult: [WorkspaceClient.FileItem: [AttributedString]] = [:]
    private var cancellables = Set<AnyCancellable>()

    func search(_ text: String, workspaceClient: WorkspaceClient?) {
        searchResult = [:]
        workspaceClient?
            .getFiles
            .sink { [weak self] files in
                guard let self = self else { return }
                files.forEach { fileItem in
                    let data = try? String(contentsOf: fileItem.url)
                    data?.split(separator: "\n").forEach { line in
                        if line.contains(text) {
                            line.ranges(of: text).forEach { range in
                                var attributedString = AttributedString()
                                attributedString.append(
                                    AttributedString(String(line[line.startIndex..<range.lowerBound]))
                                )
                                var searchedString = AttributedString(String(line[range]))
                                searchedString.font = .system(size: 12, weight: .bold)
                                searchedString.foregroundColor = .labelColor
                                attributedString.append(searchedString)
                                attributedString.append(
                                    AttributedString(String(line[range.upperBound..<line.endIndex]))
                                )
                                var lines = self.searchResult[fileItem] ?? []
                                lines.append(attributedString)
                                self.searchResult[fileItem] = lines
                            }
                        }
                    }
                }
                print(self.searchResult)
            }
            .store(in: &cancellables)
    }
}

extension StringProtocol where Index == String.Index {
    func ranges<T: StringProtocol>(
        of substring: T,
        options: String.CompareOptions = [],
        locale: Locale? = nil
    ) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while let result = range(
            of: substring,
            options: options,
            range: (ranges.last?.upperBound ?? startIndex)..<endIndex,
            locale: locale) {
            ranges.append(result)
        }
        return ranges
    }
}
