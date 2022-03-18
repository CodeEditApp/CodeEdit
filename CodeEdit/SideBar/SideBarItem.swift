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
        NavigationLink(tag: item.id, selection: $workspace.selectedId) {
            ZStack {
                if let codeFile = workspace.openedCodeFiles[item] {
                    CodeFileView(codeFile: codeFile)
                        .safeAreaInset(edge: .top, spacing: 0) {
                            VStack(spacing: 0) {
                                TabBar(windowController: windowController, workspace: workspace)
                                BreadcrumbsView(item, workspace: workspace)
                            }
                        }
                } else {
                    Text("File cannot be opened")
                }
            }
            .onAppear { workspace.openFile(item: item) }
        } label: {
			Label(item.url.lastPathComponent, systemImage: item.systemImage)
				.accentColor(item.iconColor)
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
