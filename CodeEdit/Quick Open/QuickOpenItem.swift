//
//  QuickOpenItem.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI
import WorkspaceClient

public struct QuickOpenItem: View {
    let baseDirectory: URL
    let fileItem: WorkspaceClient.FileItem

    public var body: some View {
        HStack(spacing: 8) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: fileItem.url.path))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
            VStack(alignment: .leading) {
                Text(fileItem.url.lastPathComponent).font(.system(size: 13))
                    .lineLimit(1)
                Text(fileItem.url.path.replacingOccurrences(of: baseDirectory.path, with: ""))
                    .font(.system(size: 11))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }.padding(.trailing, 15)
            Spacer()
        }
        .contentShape(Rectangle())
    }
}
