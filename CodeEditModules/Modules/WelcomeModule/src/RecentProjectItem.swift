//
//  RecentProjectView.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI
import WorkspaceClient

public struct RecentProjectItem: View {
    var fileItem: WorkspaceClient.FileItem

    public init(projectPath: String) {
        self.fileItem = WorkspaceClient.FileItem(url: URL(fileURLWithPath: projectPath), children: [])
    }

    public var body: some View {
        HStack(spacing: 15) {
            Image(systemName: fileItem.fileIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24)
            VStack(alignment: .leading) {
                Text(fileItem.fileName).font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                Text(fileItem.url.path)
                    .font(.system(size: 13))
                    .lineLimit(1)
                    .truncationMode(.head)
            }
            Spacer()
        }
        .padding(8)
        .contentShape(Rectangle())
        .cornerRadius(8)
    }
}

struct RecentProjectItem_Previews: PreviewProvider {
    static var previews: some View {
        RecentProjectItem(projectPath: "/repos/CodeEdit")
            .frame(width: 300)
    }
}
