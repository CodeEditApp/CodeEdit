//
//  TabBarContextMenu.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/4/22.
//

import Foundation
import SwiftUI

extension View {
    func tabBarContextMenu(item: WorkspaceClient.FileItem, isTemporary: Bool) -> some View {
        modifier(TabBarContextMenu(item: item, isTemporary: isTemporary))
    }
}

struct TabBarContextMenu: ViewModifier {
    init(
        item: WorkspaceClient.FileItem,
        isTemporary: Bool
    ) {
        self.item = item
        self.isTemporary = isTemporary
    }

    @EnvironmentObject
    var workspace: WorkspaceDocument

    @EnvironmentObject
    var tabs: TabGroupData

    @Environment(\.splitEditor) var splitEditor

    private var item: WorkspaceClient.FileItem
    private var isTemporary: Bool

    // swiftlint:disable:next function_body_length
    func body(content: Content) -> some View {
        content.contextMenu(menuItems: {
            Group {
                Button("Split Up") {
                    moveToNewSplit(.top)
                }
                Button("Split Down") {
                    moveToNewSplit(.bottom)
                }
                Button("Split Left") {
                    moveToNewSplit(.leading)
                }
                Button("Split Right") {
                    moveToNewSplit(.trailing)
                }
                Button("Close Tab") {
                    withAnimation {
                        tabs.closeTab(item: item)
                    }
                }
                .keyboardShortcut("w", modifiers: [.command])

                Button("Close Other Tabs") {
                    withAnimation {
                        tabs.files.forEach { file in
                            if file != item {
                                tabs.closeTab(item: file)
                            }
                        }
                    }
                }
                Button("Close Tabs to the Right") {
                    withAnimation {
                        if let index = tabs.files.firstIndex(of: item) {
                            tabs.files[index...].forEach {
                                tabs.closeTab(item: $0)
                            }
                        }
                    }
                }
                // Disable this option when current tab is the last one.
                .disabled(tabs.files.last == item)

                Button("Close All") {
                    withAnimation {
                        tabs.files.forEach {
                            tabs.closeTab(item: $0)
                        }
                    }
                }

                if isTemporary {
                    Button("Keep Open") {
                        workspace.convertTemporaryTab()
                    }
                }
            }

            Divider()

            if let item = item as? WorkspaceClient.FileItem {
                Group {
                    Button("Copy Path") {
                        copyPath(item: item)
                    }

                    Button("Copy Relative Path") {
                        copyRelativePath(item: item)
                    }
                }

                Divider()

                Group {
                    Button("Show in Finder") {
                        item.showInFinder()
                    }

                    Button("Reveal in Project Navigator") {
                        workspace.listenerModel.highlightedFileItem = item
                    }

                    Button("Open in New Window") {

                    }
                    .disabled(true)
                }
            }
        })
    }

    // MARK: - Actions

    /// Copies the absolute path of the given `FileItem`
    /// - Parameter item: The `FileItem` to use.
    private func copyPath(item: WorkspaceClient.FileItem) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item.url.standardizedFileURL.path, forType: .string)
    }

    func moveToNewSplit(_ edge: Edge) {
        let newTabGroup = TabGroupData(files: [item])
        splitEditor(edge, newTabGroup)
        tabs.closeTab(item: item)
    }

    /// Copies the relative path from the workspace folder to the given file item to the pasteboard.
    /// - Parameter item: The `FileItem` to use.
    private func copyRelativePath(item: WorkspaceClient.FileItem) {
        guard let rootPath = workspace.workspaceClient?.folderURL() else {
            return
        }
        // Calculate the relative path
        var rootComponents = rootPath.standardizedFileURL.pathComponents
        var destinationComponents = item.url.standardizedFileURL.pathComponents

        // Remove any same path components
        while !rootComponents.isEmpty && !destinationComponents.isEmpty
                && rootComponents.first == destinationComponents.first {
            rootComponents.remove(at: 0)
            destinationComponents.remove(at: 0)
        }

        // Make a "../" for each remaining component in the root URL
        var relativePath: String = String(repeating: "../", count: rootComponents.count)
        // Add the remaining components for the destination url.
        relativePath += destinationComponents.joined(separator: "/")

        // Copy it to the clipboard
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(relativePath, forType: .string)
    }
}
