//
//  SideBarItem.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//  Context Menu by Nanashi Li on 20.03.22.
//

import SwiftUI
import WorkspaceClient
import CodeFile

struct ProjectNavigatorItem: View {
	@Environment(\.controlActiveState) var activeState
	@Environment(\.colorScheme) var colorScheme
	@AppStorage(FileIconStyle.storageKey) var iconStyle: FileIconStyle = .default

	/// The `FileItem` for this view
	var item: WorkspaceClient.FileItem

	/// The current ``WorkspaceDocument``
	@ObservedObject var workspace: WorkspaceDocument

	/// The current `NSWindowController`
	var windowController: NSWindowController

	/// If ``item`` is a folder, load one level of children if expanded
	/// This fixes animation glitches when unfolding a folder while
	/// maintaining performance.
	///
	/// This will be set to true once a parent folder expands
	@Binding var shouldloadChildren: Bool

	/// The current selected ``item`` in the list
	@Binding var selectedId: WorkspaceClient.FileItem.ID?

	/// Tracks the `DisclosureGroup`s `isExpanded` property in order
	/// to set ``shouldloadChildren`` for its child items
	@State private var isExpanded: Bool = false

	var body: some View {
		if item.children == nil {
			sidebarFileItem(item)
				.id(item)
		} else {
			sidebarFolderItem(item)
				.id(item.id)
		}
	}

	func sidebarFileItem(_ item: WorkspaceClient.FileItem) -> some View {
		HStack {
			Image(systemName: item.systemImage)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 12, height: 12, alignment: .center)
				.foregroundColor(iconColor)
				.opacity(activeState == .inactive ? 0.45 : 1)
			Text(item.url.lastPathComponent)
				.font(.subheadline)
				.frame(maxWidth: .infinity, alignment: .leading)
				.contentShape(Rectangle())
		}
		.listRowInsets(.init())
		.contextMenu { contextMenuContent(false) }
	}

	@ViewBuilder
	func sidebarFolderItem(_ item: WorkspaceClient.FileItem) -> some View {
		DisclosureGroup(isExpanded: $isExpanded) {
			if shouldloadChildren { // Only load when expanded -> Improves performance massively
				ForEach(item.children!.sortItems(foldersOnTop: workspace.sortFoldersOnTop)) { child in
					ProjectNavigatorItem(
						item: child,
						workspace: workspace,
						windowController: windowController,
						shouldloadChildren: $isExpanded,
						selectedId: $selectedId
					)
				}
			}
		} label: {
			HStack {
				Image(systemName: item.systemImage)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 12, height: 12, alignment: .center)
					.foregroundColor(.secondary)
					.opacity(activeState == .inactive ? 0.45 : 1)
				Text(item.url.lastPathComponent)
					.font(.subheadline)
					.frame(maxWidth: .infinity, alignment: .leading)
					.contentShape(Rectangle())
			}
			.contextMenu { contextMenuContent(true) }
		}
	}

	private var iconColor: Color {
		return iconStyle == .color ? item.iconColor : .secondary
	}

	// TODO: Some implementations still need to be done
	/// maximum number of views in a container is exceeded (in SwiftUI). The max = 10
	@ViewBuilder
	private func contextMenuContent(_ isFolder: Bool) -> some View {
		Button("Show in Finder") { item.showInFinder() }
		Group {
			Divider()
			Button("Open in Tab") {
				// Open a new tab
			}
			Button("Open in New Window") {
				// Open a new window
			}
			Divider()
		}
		Button("Show File Inspector") { /* Show File Inspector */ }
		Group {
			Divider()
			Button("New File") {
				item.addFile(fileName: "randomFile.txt")
			}
			Button("Add files to folder") {
				// Add Files to Folder
			}
			Divider()
		}
		Button("Delete") { item.delete() }
		Group {
			Divider()
			Button("New Folder") {
				item.addFolder(folderName: "Test Folder")
			}
			Button("New Folder from Selection") {
				// New Group from Selection
			}
			Divider()
		}
		Group {
			Button("Sort by Name") {
				// Sort folder items by name
			}.disabled(isFolder ? false : true)
			Button("Sort by Type") {
				// Sort folder items by file type
			}.disabled(isFolder ? false : true)
			Divider()
		}
		Button("Find in Selected Groups...") {}
			.disabled(isFolder ? false : true)
		Divider()
		Menu("Source Control") {
			Button("Commit Selected File") {
				// Commit selected file
			}
			Divider()
			Button("Discard Changes in Selected File") {
				// Discard changes made to the selected file
			}
			Divider()
			Button("Add") {
				// Add file to git
			}
			Button("Mark as Resolved") {
				// Mark file as resolved
			}
		}
	}
}
