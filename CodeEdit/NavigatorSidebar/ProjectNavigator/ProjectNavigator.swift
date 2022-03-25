//
//  NavigatorSidebar.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 25.03.22.
//

import SwiftUI
import WorkspaceClient

struct ProjectNavigator: View {
	@ObservedObject var workspace: WorkspaceDocument
	var windowController: NSWindowController

	@State private var selection: WorkspaceClient.FileItem.ID?

    var body: some View {
		List(selection: $selection) {
			Text(workspace.workspaceClient?.folderURL()?.lastPathComponent ?? "Empty")
				.font(.callout.bold())
				.foregroundColor(.secondary)
				.padding(.bottom, 4)
			ForEach(workspace.selectionState.fileItems.sortItems(foldersOnTop: workspace.sortFoldersOnTop)) { item in
				ProjectNavigatorItem(
					item: item,
					workspace: workspace,
					windowController: windowController,
					selectedId: $selection
				)
			}
		}
		.environment(\.defaultMinListRowHeight, 8)
		.listRowInsets(.init())
		.onChange(of: selection) { newValue in
			guard let id = newValue,
				  let item = try? workspace.workspaceClient?.getFileItem(id),
				  item.children == nil
			else { return }
			workspace.openFile(item: item)
		}
		.onChange(of: workspace.selectionState.selectedId) { newValue in
			selection = newValue
		}
    }
}
