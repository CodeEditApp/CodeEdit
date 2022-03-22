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
                .contextMenu { contextMenuContent(true) }
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
        }
    }

    // TODO: Some implementations still need to be done
    /// maximum number of views in a container is exceeded (in SwiftUI). The max = 10
    @ViewBuilder
    private func contextMenuContent(_ isFolder: Bool) -> some View {
        Button("Show in Finder", action: {
            item.showInFinder()
        })
        Group {
            Divider()
            Button("Open in Tab", action: {
                // Open a new tab
            })
            Button("Open in New Window", action: {
                // Open a new window
            })
            Divider()
        }
        Button("Show File Inspector", action: {
            // Show File Inspector
        })
        Group {
            Divider()
            Button("New File", action: {
                item.addFile(fileName: "randomFile.txt")
            })
            Button("Add files to folder", action: {
                // Add Files to Folder
            })
            Divider()
        }
        Button("Delete", action: {
            item.delete()
        })
        Group {
            Divider()
            Button("New Group", action: {
                item.addFolder(folderName: "Test Folder")
            })
            Button("New Group without Folder", action: {
                // New Group without Folder
            })
            Button("New Group from Selection", action: {
                // New Group from Selection
            })
            Divider()
        }
        Group {
            Button("Sort by Name", action: {
                // Sort folder items by name
            }).disabled(isFolder ? false : true)
            Button("Sort by Type", action: {
                // Sort folder items by file type
            }).disabled(isFolder ? false : true)
            Divider()
        }
        Button("Find in Selected Groups...", action: {
        }).disabled(isFolder ? false : true)
        Divider()
        Menu("Source Control") {
            Button("Commit Selected File", action: {
                // Commit selected file
            })
            Divider()
            Button("Discard Changes in Selected File", action: {
                // Discard changes made to the selected file
            })
            Divider()
            Button("Add", action: {
                // Add file to git
            })
            Button("Mark as Resolved", action: {
                // Mark file as resolved
            })
        }
    }
}
