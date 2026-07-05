//
//  ProjectNavigatorViewController+NSOutlineViewDataSource.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/13/24.
//

import AppKit
import CodeEditCore

extension ProjectNavigatorViewController: NSOutlineViewDataSource {
    /// Retrieves the children of a given item for the outline view, applying the current filter if necessary.
    private func getOutlineViewItems(for item: CEWorkspaceFile) -> [CEWorkspaceFile] {
        if let cachedChildren = filteredContentChildren[item] {
            return cachedChildren
                .sorted { lhs, rhs in
                    workspace?.projectNavigatorViewModel?.sortFoldersOnTop == true
                        ? lhs.isFolder && !rhs.isFolder : lhs.name < rhs.name
                }
        }

        if let workspace, let children = workspace.workspaceFileManager?.childrenOfFile(item) {
            let navigatorFilter = workspace.projectNavigatorViewModel?.navigatorFilter ?? ""
            let sourceControlFilter = workspace.projectNavigatorViewModel?.sourceControlFilter ?? false
            let sortFoldersOnTop = workspace.projectNavigatorViewModel?.sortFoldersOnTop ?? true

            if !navigatorFilter.isEmpty || sourceControlFilter {
                let filteredChildren = children.filter {
                    fileSearchMatches(
                        navigatorFilter,
                        for: $0,
                        sourceControlFilter: sourceControlFilter
                    )
                }

                filteredContentChildren[item] = filteredChildren
                return filteredChildren
            }

            return children
                .sorted { lhs, rhs in
                    sortFoldersOnTop ? lhs.isFolder && !rhs.isFolder : lhs.name < rhs.name
                }
        }

        return []
    }

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? CEWorkspaceFile {
            return getOutlineViewItems(for: item).count
        }
        return content.count
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? CEWorkspaceFile {
            return getOutlineViewItems(for: item)[index]
        }
        return content[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? CEWorkspaceFile {
            return item.isFolder
        }
        return false
    }

    /// Write dragged file(s) to pasteboard
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        guard let fileItem = item as? CEWorkspaceFile else { return nil }
        return fileItem.url as NSURL
    }

    /// Declare valid drop target
    func outlineView(
        _ outlineView: NSOutlineView,
        validateDrop info: NSDraggingInfo,
        proposedItem item: Any?,
        proposedChildIndex index: Int
    ) -> NSDragOperation {
        guard let fileItem = item as? CEWorkspaceFile else { return [] }
        // -1 index indicates that we are hovering over a row in outline view (folder or file)
        if index == -1 {
            if !fileItem.isFolder {
                outlineView.setDropItem(fileItem.parent, dropChildIndex: index)
            }
            return info.draggingSourceOperationMask == .copy ? .copy : .move
        }
        return []
    }

    /// Handle successful or unsuccessful drop
    func outlineView(
        _ outlineView: NSOutlineView,
        acceptDrop info: NSDraggingInfo,
        item: Any?,
        childIndex index: Int
    ) -> Bool {
        guard let pasteboardItems = info.draggingPasteboard.readObjects(forClasses: [NSURL.self]) else { return false }
        let fileItemURLS = pasteboardItems.compactMap { $0 as? URL }

        guard let fileItemDestination = item as? CEWorkspaceFile,
              let workspace else { return false }

        let useCase = AcceptDroppedFilesUseCase()
        let isCopy = info.draggingSourceOperationMask == .copy

        do {
            let operations = try useCase.execute(
                urls: fileItemURLS,
                destinationParent: fileItemDestination,
                isCopyOperation: isCopy,
                in: workspace,
                confirmReplace: { [weak self] fileName in
                    self?.replaceFileDialog(fileName: fileName) ?? false
                }
            )

            for operation in operations {
                if operation.isCopy {
                    self.copyFile(file: operation.source, to: operation.destination)
                } else {
                    self.moveFile(file: operation.source, to: operation.destination)
                }
            }
            return !operations.isEmpty
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func replaceFileDialog(fileName: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = """
        A file or folder with the name \(fileName) already exists in the destination folder. Do you want to replace it?
        """
        alert.informativeText = "This action is irreversible!"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Replace")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }
}
