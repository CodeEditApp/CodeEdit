//
//  SideBar.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import WorkspaceClient

struct SideBar: View {
    @ObservedObject var workspace: WorkspaceDocument
    var windowController: NSWindowController
	@State private var selection: Int = 0
    
    var body: some View {
        List {
            switch selection {
            case 0:
                Section(header: Text(workspace.fileURL?.lastPathComponent ?? "Unknown")) {
                    ForEach(workspace.fileItems.sortItems(foldersOnTop: workspace.sortFoldersOnTop)) { item in // Instead of OutlineGroup
                        SideBarItem(
                            item: item,
                            workspace: workspace,
                            windowController: windowController
                        ).onDrag {
                            let result = NSItemProvider.init(contentsOf: item.url.absoluteURL)!
                            print(result.debugDescription)
                            return result
                        }
                    }
                }
            default: EmptyView()
            }
        }
        .safeAreaInset(edge: .top) {
            SideBarToolbarTop(selection: $selection)
                .padding(.bottom, -8)
        }
        .safeAreaInset(edge: .bottom) {
            SideBarToolbarBottom(workspace: workspace)
        }
    }
}
