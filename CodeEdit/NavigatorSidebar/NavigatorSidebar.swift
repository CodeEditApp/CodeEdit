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
                List {
                    Section(header: Text(workspace.fileURL?.lastPathComponent ?? "Unknown")) {
                        ForEach(
                            workspace.fileItems.sortItems(foldersOnTop: workspace.sortFoldersOnTop)
                        ) { item in // Instead of OutlineGroup
                            NavigatorSidebarItem(
                                item: item,
                                workspace: workspace,
                                windowController: windowController
                            )
                        }
                    }
                }
            case 2:
                SidebarSearch(workspace: workspace, windowController: windowController)
            default: EmptyView()
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
