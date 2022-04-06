//
//  NavigatorSidebar.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 25.03.22.
//

import SwiftUI
import WorkspaceClient

/// # Project Navigator - Sidebar
///
/// A list that functions as a project navigator, showing collapsable folders
/// and files.
///
/// When selecting a file it will open in the editor.
///
struct ProjectNavigator: View {
    @ObservedObject var workspace: WorkspaceDocument
    var windowController: NSWindowController

    /// The `ID` of the currently selected file/folder. If none is selected this is `nil`
    @State
    private var selection: WorkspaceClient.FileItem.ID?

    var body: some View {
        SidebarOutline(workspace: workspace)
//        List(selection: $selection) {
//            Section {
//                ForEach(
//                    workspace.selectionState.fileItems.sortItems(foldersOnTop: workspace.sortFoldersOnTop)
//                ) { item in
//                    ProjectNavigatorItem(
//                        item: item,
//                        workspace: workspace,
//                        windowController: windowController,
//                        shouldloadChildren: .constant(true), // First level of children should always be loaded
//                        selectedId: $selection
//                    )
//                }
//            } header: {
//                Text(projectName)
//                    .padding(.vertical, 8)
//            }
//        }
//        .listStyle(.sidebar)
//        .listRowInsets(.init())
//        .onChange(of: selection) { newValue in
//            guard let id = newValue,
//                  let item = try? workspace.workspaceClient?.getFileItem(id),
//                  item.children == nil
//            else { return }
//            workspace.openFile(item: item)
//        }
//        .onChange(of: workspace.selectionState.selectedId) { newValue in
//            selection = newValue
//        }
    }

    /// The name of the project (name of the selected top-level folder)
    private var projectName: String {
        workspace.workspaceClient?.folderURL()?.lastPathComponent ?? "Project"
    }
}
