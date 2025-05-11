//
//  IssueNavigatorMenuActions.swift
//  CodeEdit
//
//  Created by Abe Malla on 4/3/25.
//

import AppKit
import SwiftUI

extension IssueNavigatorMenu {
    /// - Returns: the currently selected `IssueNode` items in the outline view.
    func selectedNodes() -> [any IssueNode] {
        let selectedItems = sender.outlineView.selectedRowIndexes.compactMap {
            sender.outlineView.item(atRow: $0) as? (any IssueNode)
        }

        if let menuItem = sender.outlineView.item(atRow: sender.outlineView.clickedRow) as? (any IssueNode) {
            if !selectedItems.contains(where: { $0.id == menuItem.id }) {
                return [menuItem]
            }
        }

        return selectedItems
    }

    /// Finds the file node that contains a diagnostic node
    private func findFileNode(for diagnosticNode: DiagnosticIssueNode) -> FileIssueNode? {
        // First try to find it by checking parents in the outline view
        if let parent = sender.outlineView.parent(forItem: diagnosticNode) as? FileIssueNode {
            return parent
        }

        // Fallback: Look for a file with matching URI
        for row in 0..<sender.outlineView.numberOfRows {
            if let fileNode = sender.outlineView.item(atRow: row) as? FileIssueNode {
                if fileNode.uri == diagnosticNode.fileUri {
                    return fileNode
                }
            }
        }

        return nil
    }

    /// - Returns: the relevant file nodes, converting diagnostic nodes to their parent file nodes if needed
    private func selectedFileNodes() -> [FileIssueNode] {
        let nodes = selectedNodes()
        var fileNodes = [FileIssueNode]()

        for node in nodes {
            if let fileNode = node as? FileIssueNode {
                if !fileNodes.contains(where: { $0.id == fileNode.id }) {
                    fileNodes.append(fileNode)
                }
            } else if let diagnosticNode = node as? DiagnosticIssueNode {
                if let fileNode = findFileNode(for: diagnosticNode),
                   !fileNodes.contains(where: { $0.id == fileNode.id }) {
                    fileNodes.append(fileNode)
                }
            }
        }

        return fileNodes
    }

    /// Copies the details of the issue node that was selected
    @objc
    func copyIssue() {
        let textsToCopy = selectedNodes().compactMap { node -> String? in
            if let diagnosticNode = node as? DiagnosticIssueNode {
                return diagnosticNode.name
            } else if let fileNode = node as? FileIssueNode {
                return fileNode.name
            } else {
                return node.name
            }
        }

        if !textsToCopy.isEmpty {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.writeObjects([textsToCopy.joined(separator: "\n") as NSString])
        }
    }

    /// Action that opens **Finder** at the items location.
    @objc
    func showInFinder() {
        let fileURLs = selectedFileNodes().compactMap { URL(string: $0.uri) }
        NSWorkspace.shared.activateFileViewerSelecting(fileURLs)
    }

    @objc
    func revealInProjectNavigator() {
        guard let fileNode = selectedFileNodes().first,
              let fileURL = URL(string: fileNode.uri),
              let workspaceFileManager = workspace?.workspaceFileManager,
              let file = workspaceFileManager.getFile(fileURL.path) else {
            return
        }
        workspace?.listenerModel.highlightedFileItem = file
    }

    /// Action that opens the item, identical to clicking it.
    @objc
    func openInTab() {
        for fileNode in selectedFileNodes() {
            if let fileURL = URL(string: fileNode.uri),
               let workspaceFileManager = workspace?.workspaceFileManager,
               let file = workspaceFileManager.getFile(fileURL.path) {
                workspace?.editorManager?.activeEditor.openTab(file: file)
            }
        }
    }

    /// Action that opens in an external editor
    @objc
    func openWithExternalEditor() {
        let fileURLs = selectedFileNodes().compactMap { URL(string: $0.uri)?.path }

        if !fileURLs.isEmpty {
            let process = Process()
            process.launchPath = "/usr/bin/open"
            process.arguments = fileURLs
            try? process.run()
        }
    }
}
