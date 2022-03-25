//
//  NavigatorSidebar.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 25.03.22.
//

import SwiftUI

struct NavigatorSidebar: View {
	@ObservedObject var workspace: WorkspaceDocument
	var windowController: NSWindowController

    var body: some View {
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
    }
}
