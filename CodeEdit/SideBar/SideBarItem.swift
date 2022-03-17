//
//  SideBarItem.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import WorkspaceClient

struct SideBarItem: View {

	var item: WorkspaceClient.FileItem

	var directoryURL: URL
	var workspaceClient: WorkspaceClient
	@Binding var openFileItems: [WorkspaceClient.FileItem]
	@Binding var selectedId: UUID?
	@State var isExpanded: Bool = false

	var body: some View {
		if item.children == nil {
			// TODO: Add selection indicator
			sidebarFileItem(item)
				.id(item.id)
		} else {
			sidebarFolderItem(item)
				.id(item.id)
		}
	}

	func sidebarFileItem(_ item: WorkspaceClient.FileItem) -> some View {
		NavigationLink(tag: item.id, selection: $selectedId) {
			WorkspaceEditorView(item: item)
				.overlay(alignment: .top) {
					TabBar(openFileItems: $openFileItems, selectedId: $selectedId)
				}
				.onAppear { selectItem(item) }
		} label: {
			Label(item.url.lastPathComponent, systemImage: item.systemImage)
				.foregroundColor(.secondary)
				.font(.callout)
		}
	}

	func sidebarFolderItem(_ item: WorkspaceClient.FileItem) -> some View {
		DisclosureGroup(isExpanded: $isExpanded) {
			if isExpanded { // Only load when expanded -> Improves performance massively
				ForEach(item.children!) { child in
					SideBarItem(item: child,
								directoryURL: directoryURL,
								workspaceClient: workspaceClient,
								openFileItems: $openFileItems,
								selectedId: $selectedId)
				}
			}
		} label: {
			Label(item.url.lastPathComponent, systemImage: item.systemImage)
				.accentColor(.secondary)
				.font(.callout)
		}
	}

	func selectItem(_ item: WorkspaceClient.FileItem) {
		withAnimation {
			if !openFileItems.contains(item) { openFileItems.append(item) }
		}
		selectedId = item.id
	}
}
