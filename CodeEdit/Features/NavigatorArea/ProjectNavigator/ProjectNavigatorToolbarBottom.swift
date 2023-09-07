//
//  ProjectNavigatorToolbarBottom.swift
//  CodeEdit
//
//  Created by TAY KAI QUAN on 23/7/22.
//

import SwiftUI

struct ProjectNavigatorToolbarBottom: View {
    @Environment(\.controlActiveState)
    private var activeState

    @Environment(\.colorScheme)
    private var colorScheme

    @EnvironmentObject var workspace: WorkspaceDocument

    @State var filter: String = ""

    var body: some View {
        HStack {
            addNewFileButton
                .frame(width: 20)
                .padding(.leading, 10)
            HStack {
                sortButton
                TextField("Filter", text: $filter)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
                if !filter.isEmpty {
                    clearFilterButton
                        .padding(.trailing, 5)
                }
            }
            .onChange(of: filter, perform: {
                workspace.filter = $0
            })
            .padding(.vertical, 3)
            .background(colorScheme == .dark ? Color(hex: "#FFFFFF").opacity(0.1) : Color(hex: "#808080").opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray, lineWidth: 0.5).cornerRadius(6))
            .padding(.trailing, 5)
            .padding(.leading, -8)
        }
        .frame(height: 29, alignment: .center)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    private var addNewFileButton: some View {
        Menu {
            Button("Add File") {
                guard let folderURL = workspace.workspaceFileManager?.folderUrl,
                      let root = try? workspace.workspaceFileManager?.getFile(folderURL.path) else { return }

                // TODO: use currently selected file instead of root
                root.addFile(fileName: "untitled")
            }
            Button("Add Folder") {
                guard let folderURL = workspace.workspaceFileManager?.folderUrl,
                      let root = try? workspace.workspaceFileManager?.getFile(folderURL.path) else { return }

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

    /// We clear the text and remove the first responder which removes the cursor
    /// when the user clears the filter.
    private var clearFilterButton: some View {
        Button {
            filter = ""
            NSApp.keyWindow?.makeFirstResponder(nil)
        } label: {
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.hierarchical)
        }
        .buttonStyle(.plain)
        .opacity(activeState == .inactive ? 0.45 : 1)
    }
}
