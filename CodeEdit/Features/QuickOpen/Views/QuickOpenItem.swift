//
//  QuickOpenItem.swift
//  CodeEditModules/QuickOpen
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI

struct QuickOpenItem: View {
    private let baseDirectory: URL
    private let fileURL: URL
    private let textToMatch: String

    init(
        baseDirectory: URL,
        fileURL: URL,
        textToMatch: String
    ) {
        self.baseDirectory = baseDirectory
        self.fileURL = fileURL
        self.textToMatch = textToMatch
    }

    var relativePathComponents: ArraySlice<String> {
        return fileURL.pathComponents.dropFirst(baseDirectory.pathComponents.count).dropLast()
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: fileURL.path))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            VStack(alignment: .leading, spacing: 0) {
                QuickSearchResultLabel(labelName: fileURL.lastPathComponent, textToMatch: textToMatch)
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
