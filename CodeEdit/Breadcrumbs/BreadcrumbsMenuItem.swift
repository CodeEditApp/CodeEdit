//
//  BreadcrumbsMenuItem.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/26.
//

import SwiftUI
import WorkspaceClient

struct BreadcrumbsMenuItem: View {
    /// Current `WorkspaceDocument`
    @ObservedObject var workspace: WorkspaceDocument

    /// The `FileItem` for this view
    var fileItem: WorkspaceClient.FileItem

    var body: some View {
        if let children = fileItem.children?.sortItems(foldersOnTop: true), !children.isEmpty {
            // Folder
            Menu {
                ForEach(children, id: \.self) { child in
                    BreadcrumbsMenuItem(workspace: workspace, fileItem: child)
                }
            } label: {
                BreadcrumbsComponent(fileItem.fileName, systemImage: "folder.fill", color: .secondary)
            }
        } else {
            // File
            Button {
                workspace.openFile(item: fileItem)
            } label: {
                BreadcrumbsComponent(fileItem.fileName, systemImage: fileItem.fileIcon, color: fileItem.iconColor)
            }
        }
    }
}
