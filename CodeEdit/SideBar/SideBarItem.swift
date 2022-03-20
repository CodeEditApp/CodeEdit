//
//  SideBarItem.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import WorkspaceClient
import CodeFile

struct SideBarItem: View {

	@AppStorage(FileIconStyle.storageKey) var iconStyle: FileIconStyle = .default

	var item: WorkspaceClient.FileItem
    @ObservedObject var workspace: WorkspaceDocument
    var windowController: NSWindowController
	@State var isExpanded: Bool = false

	var body: some View {
		if item.children == nil {
			sidebarFileItem(item)
				.id(item.id)
		} else {
			sidebarFolderItem(item)
				.id(item.id)
		}
	}

    func sidebarFileItem(_ item: WorkspaceClient.FileItem) -> some View {
        NavigationLink {
            ZStack {
                if let item = workspace.openFileItems.first(where: { file in
                    return file.id == workspace.selectedId
                }) {
                    if let codeFile = workspace.openedCodeFiles[item] {
                        WorkspaceCodeFileView(codeFile: codeFile,
                                              windowController: windowController,
                                              workspace: workspace,
                                              item: item)
                    } else {
                        Text("CodeEdit cannot open this file because its file type is not supported.")
                    }
                } else {
                    Text("Open file from sidebar")
                }
            }
            .onAppear { workspace.openFile(item: item) }
        } label: {
			Label(item.url.lastPathComponent, systemImage: item.systemImage)
				.accentColor(iconStyle == .color ? item.iconColor : .secondary)
				.font(.callout)
		}
	}

	func sidebarFolderItem(_ item: WorkspaceClient.FileItem) -> some View {
		DisclosureGroup(isExpanded: $isExpanded) {
			if isExpanded { // Only load when expanded -> Improves performance massively
				ForEach(item.children!.sortItems(foldersOnTop: workspace.sortFoldersOnTop)) { child in
					SideBarItem(item: child,
								workspace: workspace,
                                windowController: windowController)
				}
			}
		} label: {
			Label(item.url.lastPathComponent, systemImage: item.systemImage)
				.accentColor(.secondary)
				.font(.callout)
		}
	}
}
