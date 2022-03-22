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

struct NavigatorSidebarItem: View {
    @AppStorage(FileIconStyle.storageKey) var iconStyle: FileIconStyle = .default
    var item: WorkspaceClient.FileItem
    @ObservedObject var workspace: WorkspaceDocument
    var windowController: NSWindowController
    @State var isExpanded: Bool = false

    var body: some View {
        if item.children == nil {
            sidebarFileItem(item)
                .id(item.id)
                .contextMenu { contextMenuContent(false) }
        } else {
            sidebarFolderItem(item)
                .id(item.id)
        }
    }

    func sidebarFileItem(_ item: WorkspaceClient.FileItem) -> some View {
        NavigationLink {
            WorkspaceCodeFileView(windowController: windowController,
                                  workspace: workspace)
            .onAppear { workspace.openFile(item: item) }
        } label: {
            Label(item.url.lastPathComponent, systemImage: item.systemImage)
                .accentColor(iconStyle == .color ? item.iconColor : .secondary)
                .font(.callout)
        }
    }

    func sidebarFolderItem(_ item: WorkspaceClient.FileItem) -> some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            if isExpanded { // Only load when expanded -> Improves performance massively
                ForEach(item.children!.sortItems(foldersOnTop: workspace.sortFoldersOnTop)) { child in
                    NavigatorSidebarItem(item: child,
                                         workspace: workspace,
                                         windowController: windowController)
                }
            }
        } label: {
            Label(item.url.lastPathComponent, systemImage: item.systemImage)
                .accentColor(.secondary)
                .font(.callout)
                // If we put the contextmenu on the DisclosureGroup,
                // We can not click sub items.
                .contextMenu { contextMenuContent(true) }
        }
    }

    // TODO: Some implementations still need to be done
    /// maximum number of views in a container is exceeded (in SwiftUI). The max = 10
    @ViewBuilder
    private func contextMenuContent(_ isFolder: Bool) -> some View {
        Button("Show in Finder") {
            item.showInFinder()
        }
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
        Button("Show File Inspector") {
            // Show File Inspector
        }
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
        Button("Delete") {
            item.delete()
        }
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
        Button("Find in Selected Groups...") {
        }.disabled(isFolder ? false : true)
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
