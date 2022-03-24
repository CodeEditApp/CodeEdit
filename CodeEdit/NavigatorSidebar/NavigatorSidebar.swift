//
//  SideBar.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import WorkspaceClient

struct NavigatorSidebar: View {
	@ObservedObject var workspace: WorkspaceDocument
	var windowController: NSWindowController
	@State private var selection: Int = 0

	var body: some View {
		ZStack {
			switch selection {
			case 0:
				ScrollView {
					VStack(alignment: .leading, spacing: 0) {
						Text(workspace.workspaceClient?.folderURL()?.lastPathComponent ?? "Empty")
							.font(.callout.bold())
							.foregroundColor(.secondary)
							.padding(.bottom, 4)
						ForEach(workspace.selectionState.fileItems.sortItems(foldersOnTop: workspace.sortFoldersOnTop)) { item in
							NavigatorSidebarItem(
								item: item,
								workspace: workspace,
								windowController: windowController
							)
						}

					}
					.padding(10)
				}
			case 2:
				SidebarSearch(state: workspace.searchState ?? .init(workspace))
			default:
				VStack { Spacer() }
			}
		}
		.safeAreaInset(edge: .top) {
			NavigatorSidebarToolbarTop(selection: $selection)
				.padding(.bottom, -8)
		}
		.safeAreaInset(edge: .bottom) {
			NavigatorSidebarToolbarBottom(workspace: workspace)
		}
	}
}
