//
//  QuickOpenItem.swift
//  CodeEditModules/QuickOpen
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI

struct QuickOpenItem: View {

    @EnvironmentObject var workspace: WorkspaceDocument

    let fileItem: File

    var relativePathComponents: ArraySlice<String> {
        guard let base = workspace.fileURL else { return [] }
        return fileItem.url.pathComponents.dropFirst(base.pathComponents.count).dropLast()
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: fileItem.url.path))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            VStack(alignment: .leading, spacing: 0) {
                Text(fileItem.url.lastPathComponent).font(.system(size: 13))
                    .lineLimit(1)
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
