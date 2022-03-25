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

	var item: WorkspaceClient.FileItem
	@ObservedObject var workspace: WorkspaceDocument
	var windowController: NSWindowController
	@Binding var selectedId: WorkspaceClient.FileItem.ID?
	@State var isExpanded: Bool = false
	var indentLevel: Double = 0

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
				.foregroundColor(
					selectionIconColor
				)
			Text(item.url.lastPathComponent)
				.font(.subheadline)
				.frame(maxWidth: .infinity, alignment: .leading)
				.contentShape(Rectangle())
		}
		.padding(.leading, indentLevel * 16 + 15.5)
		.listRowInsets(.init())
		.contextMenu { contextMenuContent(false) }
	}

	@ViewBuilder
	func sidebarFolderItem(_ item: WorkspaceClient.FileItem) -> some View {
		HStack(spacing: 0) {
			Image(systemName: "chevron.forward")
				.imageScale(.small)
				.font(.callout.bold())
				.rotationEffect(.degrees(isExpanded ? 90 : 0))
				.padding(.horizontal, 4)
				.foregroundColor(.secondary)
				.contentShape(Rectangle())
				.onTapGesture {
					withAnimation(.default.speed(1.2)) {
						isExpanded.toggle()
					}
				}
			HStack {
				Image(systemName: item.systemImage)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 12, height: 12, alignment: .center)
					.foregroundColor(folderColor)
				Text(item.url.lastPathComponent)
					.font(.subheadline)
					.frame(maxWidth: .infinity, alignment: .leading)
					.contentShape(Rectangle())
			}
		}
		.padding(.leading, indentLevel * 16)
		.contextMenu { contextMenuContent(true) }
		if isExpanded { // Only load when expanded -> Improves performance massively
			ForEach(item.children!.sortItems(foldersOnTop: workspace.sortFoldersOnTop)) { child in
				ProjectNavigatorItem(item: child,
									 workspace: workspace,
									 windowController: windowController,
									 selectedId: $selectedId,
									 indentLevel: indentLevel + 1
				)
			}
		}
	}

	private var selectionIconColor: Color {
		return iconStyle == .color ? item.iconColor : .secondary
	}

	private var folderColor: Color {
		.secondary
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
