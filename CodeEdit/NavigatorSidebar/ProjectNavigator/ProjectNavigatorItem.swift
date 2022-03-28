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

/// # Project Navigator Item
///
/// Displays a File or Folder in the ``ProjectNavigator``.
///
struct ProjectNavigatorItem: View {
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

	/// A `Label` representing a file
	private func sidebarFileItem(_ item: WorkspaceClient.FileItem) -> some View {
		Label(item.url.lastPathComponent, systemImage: item.systemImage)
			.accentColor(iconColor)
			.contextMenu {
				ProjectNavigatorContextMenu(item, isFolder: false)
			}
	}

	/// A `DisclosureGroup` representing a folder.
	///
	/// When expanded, it shows files/folders inside
	@ViewBuilder
	private func sidebarFolderItem(_ item: WorkspaceClient.FileItem) -> some View {
		DisclosureGroup(isExpanded: $isExpanded) {
			if shouldloadChildren { // Only load when parent is expanded -> Improves performance massively
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
			Label(item.url.lastPathComponent, systemImage: item.systemImage)
				.accentColor(.secondary)
				.contextMenu {
					ProjectNavigatorContextMenu(item, isFolder: true)
				}
		}
	}

	/// Returns a color depending on the set icon color style in preferences
	private var iconColor: Color {
		return iconStyle == .color ? item.iconColor : .secondary
	}
}
