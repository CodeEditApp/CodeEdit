//
//  ProjectNavigatorViewController+NSOutlineViewDataSource.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/13/24.
//

import AppKit

extension ProjectNavigatorViewController: NSOutlineViewDataSource {
    /// Retrieves the children of a given item for the outline view, applying the current filter if necessary.
    private func getOutlineViewItems(for item: CEWorkspaceFile) -> [CEWorkspaceFile] {
        if let cachedChildren = filteredContentChildren[item] {
            return cachedChildren
        }

        if let children = workspace?.workspaceFileManager?.childrenOfFile(item) {
            if let filter = workspace?.navigatorFilter, !filter.isEmpty {
                let filteredChildren = children.filter { fileSearchMatches(filter, for: $0) }
                filteredContentChildren[item] = filteredChildren
                return filteredChildren
            }

            return children
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

        guard let fileItemDestination = item as? CEWorkspaceFile else { return false }
        let destParentURL = fileItemDestination.url

        for fileItemURL in fileItemURLS {
            let destURL = destParentURL.appending(path: fileItemURL.lastPathComponent)
            // cancel dropping file item on self or in parent directory
            if fileItemURL == destURL || fileItemURL == destParentURL {
                return false
            }

            // Needs to come before call to .removeItem or else race condition occurs
            var srcFileItem: CEWorkspaceFile? = workspace?.workspaceFileManager?.getFile(fileItemURL.path)
            // If srcFileItem is nil, fileItemUrl is an external file url.
            if srcFileItem == nil {
                srcFileItem = CEWorkspaceFile(url: URL(fileURLWithPath: fileItemURL.path))
            }

            guard let srcFileItem else {
                return false
            }

            if CEWorkspaceFile.fileManager.fileExists(atPath: destURL.path) {
                let shouldReplace = replaceFileDialog(fileName: fileItemURL.lastPathComponent)
                guard shouldReplace else {
                    return false
                }
                do {
                    try CEWorkspaceFile.fileManager.removeItem(at: destURL)
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
            if info.draggingSourceOperationMask == .copy {
                self.copyFile(file: srcFileItem, to: destURL)
            } else {
                self.moveFile(file: srcFileItem, to: destURL)
            }
        }
        return true
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
