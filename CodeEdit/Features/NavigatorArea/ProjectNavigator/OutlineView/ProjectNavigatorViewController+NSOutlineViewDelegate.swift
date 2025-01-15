//
//  ProjectNavigatorViewController+NSOutlineViewDelegate.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/13/24.
//

import AppKit

extension ProjectNavigatorViewController: NSOutlineViewDelegate {
    func outlineView(
        _ outlineView: NSOutlineView,
        shouldShowCellExpansionFor tableColumn: NSTableColumn?,
        item: Any
    ) -> Bool {
        true
    }

    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        true
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let tableColumn else { return nil }

        let frameRect = NSRect(x: 0, y: 0, width: tableColumn.width, height: rowHeight)
        let cell = ProjectNavigatorTableViewCell(
            frame: frameRect,
            item: item as? CEWorkspaceFile,
            delegate: self,
            navigatorFilter: workspace?.navigatorFilter
        )
        return cell
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else { return }

        /// If multiple rows are selected, do not open any file.
        guard outlineView.selectedRowIndexes.count == 1 else { return }

        /// If only one row is selected, proceed as before
        let selectedIndex = outlineView.selectedRow

        guard let item = outlineView.item(atRow: selectedIndex) as? CEWorkspaceFile else { return }

        if !item.isFolder && shouldSendSelectionUpdate {
            shouldSendSelectionUpdate = false
            if workspace?.editorManager?.activeEditor.selectedTab?.file != item {
                workspace?.editorManager?.activeEditor.openTab(file: item, asTemporary: true)
            }
            shouldSendSelectionUpdate = true
        }
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        rowHeight // This can be changed to 20 to match Xcode's row height.
    }

    func outlineViewItemDidExpand(_ notification: Notification) {
        /// Save expanded items' state to restore when finish filtering.
        guard let workspace else { return }
        if workspace.navigatorFilter.isEmpty, let item = notification.userInfo?["NSObject"] as? CEWorkspaceFile {
            expandedItems.insert(item)
        }

        guard let id = workspace.editorManager?.activeEditor.selectedTab?.file.id,
              let item = workspace.workspaceFileManager?.getFile(id, createIfNotFound: true),
              /// update outline selection only if the parent of selected item match with expanded item
              item.parent === notification.userInfo?["NSObject"] as? CEWorkspaceFile else {
            return
        }
        /// select active file under collapsed folder only if its parent is expanding
        if outlineView.isItemExpanded(item.parent) {
            updateSelection(itemID: item.id)
        }
    }

    func outlineViewItemDidCollapse(_ notification: Notification) {
        /// Save expanded items' state to restore when finish filtering.
        guard let workspace else { return }
        if workspace.navigatorFilter.isEmpty, let item = notification.userInfo?["NSObject"] as? CEWorkspaceFile {
            expandedItems.remove(item)
        }
    }

    func outlineView(_ outlineView: NSOutlineView, itemForPersistentObject object: Any) -> Any? {
        guard let id = object as? CEWorkspaceFile.ID,
              let item = workspace?.workspaceFileManager?.getFile(id, createIfNotFound: true) else { return nil }
        return item
    }

    func outlineView(_ outlineView: NSOutlineView, persistentObjectForItem item: Any?) -> Any? {
        guard let item = item as? CEWorkspaceFile else { return nil }
        return item.id
    }

    /// Finds and selects an ``Item`` from an array of ``Item`` and their `children` based on the `id`.
    /// - Parameters:
    ///   - id: the id of the item item
    ///   - collection: the array to search for
    ///   - forcesReveal: The boolean to indicates whether or not it should force to reveal the selected file.
    func select(by id: EditorTabID, forcesReveal: Bool) {
        guard case .codeEditor(let path) = id,
              let item = workspace?.workspaceFileManager?.getFile(path, createIfNotFound: true) else {
            return
        }
        // If the user has set "Reveal file on selection change" to on or it is forced to reveal,
        // we need to reveal the item before selecting the row.
        if Settings.shared.preferences.general.revealFileOnFocusChange || forcesReveal {
            reveal(item)
        }
        let row = outlineView.row(forItem: item)
        if row == -1 {
            outlineView.deselectRow(outlineView.selectedRow)
        }
        shouldSendSelectionUpdate = false
        outlineView.selectRowIndexes(.init(integer: row), byExtendingSelection: false)
        shouldSendSelectionUpdate = true
    }

    /// Reveals the given `fileItem` in the outline view by expanding all the parent directories of the file.
    /// If the file is not found, it will present an alert saying so.
    /// - Parameter fileItem: The file to reveal.
    public func reveal(_ fileItem: CEWorkspaceFile) {
        if let parent = fileItem.parent {
            expandParent(item: parent)
        }
        let row = outlineView.row(forItem: fileItem)
        shouldSendSelectionUpdate = false
        outlineView.selectRowIndexes(.init(integer: row), byExtendingSelection: false)
        shouldSendSelectionUpdate = true

        if row < 0 {
            let alert = NSAlert()
            alert.messageText = NSLocalizedString(
                "Could not find file",
                comment: "Could not find file"
            )
            alert.runModal()
            return
        } else {
            let visibleRect = scrollView.contentView.visibleRect
            let visibleRows = outlineView.rows(in: visibleRect)
            guard !visibleRows.contains(row) else {
                /// in case that the selected file is not fully visible (some parts are out of the visible rect),
                /// `scrollRowToVisible(_:)` method brings the file where it can be fully visible.
                outlineView.scrollRowToVisible(row)
                return
            }
            let rowRect = outlineView.rect(ofRow: row)
            let centerY = rowRect.midY - (visibleRect.height / 2)
            let center = NSPoint(x: 0, y: centerY)
            /// `scroll(_:)` method alone doesn't bring the selected file to the center in some cases.
            /// calling `scrollRowToVisible(_:)` method before it makes the file reveal in the center more correctly.
            outlineView.scrollRowToVisible(row)
            outlineView.scroll(center)
        }
    }

    /// Method for recursively expanding a file's parent directories.
    /// - Parameter item:
    private func expandParent(item: CEWorkspaceFile) {
        if let parent = item.parent as CEWorkspaceFile? {
            expandParent(item: parent)
        }
        outlineView.expandItem(item)
    }

    /// Adds a tooltip to the file row.
    func outlineView( // swiftlint:disable:this function_parameter_count
        _ outlineView: NSOutlineView,
        toolTipFor cell: NSCell,
        rect: NSRectPointer,
        tableColumn: NSTableColumn?,
        item: Any,
        mouseLocation: NSPoint
    ) -> String {
        if let file = item as? CEWorkspaceFile {
            return file.name
        }
        return ""
    }
}
