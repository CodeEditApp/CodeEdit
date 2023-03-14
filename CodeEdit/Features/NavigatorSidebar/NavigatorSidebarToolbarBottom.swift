//
//  SideBarToolbarBottom.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct NavigatorSidebarToolbarBottom: View {
    @Environment(\.controlActiveState)
    private var activeState

    @EnvironmentObject
    var workspace: WorkspaceDocument

    var body: some View {
        HStack(spacing: 10) {
            addNewFileButton
            Spacer()
            sortButton
        }
        .frame(height: 29)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 4)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    private var addNewFileButton: some View {
        Menu {
            Button("Add File") {
                guard let folderURL = workspace.workspaceFileManager?.folderUrl,
                      let root = try? workspace.workspaceFileManager?.getFileItem(folderURL.path) else { return }

                // TODO: use currently selected file instead of root
                root.addFile(fileName: "untitled")
            }
            Button("Add Folder") {
                guard let folderURL = workspace.workspaceFileManager?.folderUrl,
                      let root = try? workspace.workspaceFileManager?.getFileItem(folderURL.path) else { return }

                // TODO: use currently selected file instead of root
                root.addFolder(folderName: "untitled")
            }
        } label: {
            Image(systemName: "plus")
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .frame(maxWidth: 30)
        .opacity(activeState == .inactive ? 0.45 : 1)
    }

    private var sortButton: some View {
        Menu {
            Button {
                workspace.sortFoldersOnTop.toggle()
            } label: {
                Text(workspace.sortFoldersOnTop ? "Alphabetically" : "Folders on top")
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
        .menuStyle(.borderlessButton)
        .frame(maxWidth: 30)
        .opacity(activeState == .inactive ? 0.45 : 1)
    }
}
