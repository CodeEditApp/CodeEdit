//
//  BreadcrumbsMenuItem.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/26.
//

import SwiftUI
import WorkspaceClient

struct BreadcrumbsMenuItem: View {
	@ObservedObject var workspace: WorkspaceDocument
	var fileItem: WorkspaceClient.FileItem

    var body: some View {
		if let children = fileItem.children?.sortItems(foldersOnTop: true), !children.isEmpty {
			// Folder
			Menu {
				ForEach(children, id: \.self) { child in
					BreadcrumbsMenuItem(workspace: workspace, fileItem: child)
				}
			} label: {
				BreadcrumbsComponent(fileItem.fileName, systemImage: fileItem.fileIcon, color: fileItem.iconColor)
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
