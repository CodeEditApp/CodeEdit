//
//  OpenQuicklyListItemView.swift
//  CodeEditModules/QuickOpen
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI

struct OpenQuicklyListItemView: View {
    private let baseDirectory: URL
    private let searchResult: OpenQuicklyViewModel.SearchResult

    init(
        baseDirectory: URL,
        searchResult: OpenQuicklyViewModel.SearchResult
    ) {
        self.baseDirectory = baseDirectory
        self.searchResult = searchResult
    }

    var relativePathComponents: ArraySlice<String> {
        return searchResult.fileURL.pathComponents.dropFirst(baseDirectory.pathComponents.count).dropLast()
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: searchResult.fileURL.path))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            VStack(alignment: .leading, spacing: 0) {
                QuickSearchResultLabel(
                    labelName: searchResult.fileURL.lastPathComponent,
                    charactersToHighlight: searchResult.matchedCharacters
                )
                Text(relativePathComponents.joined(separator: " ▸ "))
                    .font(.system(size: 10.5))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }
}
