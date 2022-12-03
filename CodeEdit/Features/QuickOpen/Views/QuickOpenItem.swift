//
//  QuickOpenItem.swift
//  CodeEditModules/QuickOpen
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI

struct QuickOpenItem: View {

    private let baseDirectory: URL
    private let fileItem: WorkspaceClient.FileItem

    init(
        baseDirectory: URL,
        fileItem: WorkspaceClient.FileItem
    ) {
        self.baseDirectory = baseDirectory
        self.fileItem = fileItem
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: fileItem.url.path))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
            VStack(alignment: .leading, spacing: 0) {
                Text(fileItem.url.lastPathComponent).font(.system(size: 13))
                    .lineLimit(1)
                Text(fileItem.url.path.replacingOccurrences(of: baseDirectory.path, with: ""))
                    .font(.system(size: 11))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }.padding(.trailing, 15)
            Spacer()
        }
    }
}
