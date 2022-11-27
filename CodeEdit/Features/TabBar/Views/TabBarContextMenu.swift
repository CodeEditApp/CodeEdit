//
//  TabBarContextMenu.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/4/22.
//

import Foundation
import SwiftUI

extension View {
    func tabBarContextMenu(item: TabBarItemRepresentable,
                           workspace: WorkspaceDocument,
                           isTemporary: Bool) -> some View {
        modifier(TabBarContextMenu(item: item, workspace: workspace, isTemporary: isTemporary))
    }
}

struct TabBarContextMenu: ViewModifier {
    init(item: TabBarItemRepresentable,
         workspace: WorkspaceDocument,
         isTemporary: Bool) {
        self.item = item
        self.workspace = workspace
        self.isTemporary = isTemporary
    }

    @ObservedObject
    var workspace: WorkspaceDocument

    private var item: TabBarItemRepresentable
    private var isTemporary: Bool

    // swiftlint:disable:next function_body_length
    func body(content: Content) -> some View {
        content.contextMenu(menuItems: {
            Group {
                Button("Close Tab") {
                    withAnimation {
                        workspace.closeTab(item: item.tabID)
                    }
                }
                .keyboardShortcut("w", modifiers: [.command])

                Button("Close Other Tabs") {
                    withAnimation {
                        workspace.closeTab(where: { $0 != item.tabID })
                    }
                }
                Button("Close Tabs to the Right") {
                    withAnimation {
                        workspace.closeTabs(after: item.tabID)
                    }
                }
                // Disable this option when current tab is the last one.
                .disabled(workspace.selectionState.openedTabs.last?.id == item.tabID.id)

                Button("Close All") {
                    withAnimation {
                        workspace.closeTabs(items: workspace.selectionState.openedTabs)
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
