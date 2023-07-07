//
//  OutlineViewController.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 07.04.22.
//

import SwiftUI

/// A `NSViewController` that handles the **ProjectNavigatorView** in the **NavigatorSideabr**.
///
/// Adds a ``outlineView`` inside a ``scrollView`` which shows the folder structure of the
/// currently open project.
final class ProjectNavigatorViewController: NSViewController {

    var scrollView: NSScrollView!
    var outlineView: NSOutlineView!

    /// Gets the folder structure
    ///
    /// Also creates a top level item "root" which represents the projects root directory and automatically expands it.
    private var content: [CEWorkspaceFile] {
        guard let folderURL = workspace?.workspaceFileManager?.folderUrl else { return [] }
        guard let root = try? workspace?.workspaceFileManager?.getFile(folderURL.path) else { return [] }
        return [root]
    }

    var workspace: WorkspaceDocument?

    var iconColor: SettingsData.FileIconStyle = .color
    var fileExtensionsVisibility: SettingsData.FileExtensionsVisibility = .showAll
    var shownFileExtensions: SettingsData.FileExtensions = .default
    var hiddenFileExtensions: SettingsData.FileExtensions = .default

    var rowHeight: Double = 22 {
        didSet {
            outlineView.rowHeight = rowHeight
            outlineView.reloadData()
        }
    }

    /// This helps determine whether or not to send an `openTab` when the selection changes.
    /// Used b/c the state may update when the selection changes, but we don't necessarily want
    /// to open the file a second time.
    private var shouldSendSelectionUpdate: Bool = true

    /// Setup the ``scrollView`` and ``outlineView``
    override func loadView() {
        self.scrollView = NSScrollView()
        self.scrollView.hasVerticalScroller = true
        self.view = scrollView

        self.outlineView = NSOutlineView()
        self.outlineView.dataSource = self
        self.outlineView.delegate = self
        self.outlineView.autosaveExpandedItems = true
        self.outlineView.autosaveName = workspace?.workspaceFileManager?.folderUrl.path ?? ""
        self.outlineView.headerView = nil
        self.outlineView.menu = ProjectNavigatorMenu(sender: self.outlineView)
        self.outlineView.menu?.delegate = self
        self.outlineView.doubleAction = #selector(onItemDoubleClicked)

        let column = NSTableColumn(identifier: .init(rawValue: "Cell"))
        column.title = "Cell"
        outlineView.addTableColumn(column)

        outlineView.setDraggingSourceOperationMask(.move, forLocal: false)
        outlineView.registerForDraggedTypes([.fileURL])

        scrollView.documentView = outlineView
        scrollView.contentView.automaticallyAdjustsContentInsets = false
        scrollView.contentView.contentInsets = .init(top: 10, left: 0, bottom: 0, right: 0)
        scrollView.scrollerStyle = .overlay
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true

        outlineView.expandItem(outlineView.item(atRow: 0))
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    /// Forces to reveal the selected file through the command regardless of the auto reveal setting
    @objc
    func revealFile(_ sender: Any) {
        updateSelection(itemID: workspace?.tabManager.activeTabGroup.selected?.id, forcesReveal: true)
    }

    /// Updates the selection of the ``outlineView`` whenever it changes.
    ///
    /// Most importantly when the `id` changes from an external view.
    /// - Parameter itemID: The id of the file or folder.
    /// - Parameter forcesReveal: The boolean to indicates whether or not it should force to reveal the selected file.
    func updateSelection(itemID: String?, forcesReveal: Bool = false) {
        guard let itemID else {
            outlineView.deselectRow(outlineView.selectedRow)
            return
        }
        select(by: .codeEditor(itemID), from: content, forcesReveal: forcesReveal)
    }

    /// Expand or collapse the folder on double click
    @objc
    private func onItemDoubleClicked() {
        guard let item = outlineView.item(atRow: outlineView.clickedRow) as? CEWorkspaceFile else { return }

        if item.children != nil {
            if outlineView.isItemExpanded(item) {
                outlineView.collapseItem(item)
            } else {
                outlineView.expandItem(item)
            }
        } else {
            workspace?.tabManager.activeTabGroup.openTab(item: item, asTemporary: false)
        }
    }

    /// Get the appropriate color for the items icon depending on the users preferences.
    /// - Parameter item: The `FileItem` to get the color for
    /// - Returns: A `NSColor` for the given `FileItem`.
    private func color(for item: CEWorkspaceFile) -> NSColor {
        if item.children == nil && iconColor == .color {
            return NSColor(item.iconColor)
        } else {
            return .secondaryLabelColor
        }
    }

    // TODO: File filtering
}

// MARK: - NSOutlineViewDataSource

extension ProjectNavigatorViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? CEWorkspaceFile {
            return item.children?.count ?? 0
        }
        return content.count
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? CEWorkspaceFile,
           let children = item.children {
            return children[index]
        }
        return content[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? CEWorkspaceFile {
            return item.children != nil
        }
        return false
    }

    /// write dragged file(s) to pasteboard
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        guard let fileItem = item as? CEWorkspaceFile else { return nil }
        return fileItem.url as NSURL
    }

    /// declare valid drop target
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

    /// handle successful or unsuccessful drop
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
            let destURL = destParentURL.appendingPathComponent(fileItemURL.lastPathComponent)
            // cancel dropping file item on self or in parent directory
            if fileItemURL == destURL || fileItemURL == destParentURL {
                return false
            }

            // Needs to come before call to .removeItem or else race condition occurs
            var srcFileItem: CEWorkspaceFile? = try? workspace?.workspaceFileManager?.getFile(fileItemURL.path)
            // If srcFileItem is nil, fileItemUrl is an external file url.
            if srcFileItem == nil {
                srcFileItem = CEWorkspaceFile(url: URL(fileURLWithPath: fileItemURL.path))
            }

            guard let srcFileItem else {
                return false
            }

            if CEWorkspaceFile.fileManger.fileExists(atPath: destURL.path) {
                let shouldReplace = replaceFileDialog(fileName: fileItemURL.lastPathComponent)
                guard shouldReplace else {
                    return false
                }
                do {
                    try CEWorkspaceFile.fileManger.removeItem(at: destURL)
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

// MARK: - NSOutlineViewDelegate
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

        return ProjectNavigatorTableViewCell(frame: frameRect, item: item as? CEWorkspaceFile, delegate: self)
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else {
            return
        }

        let selectedIndex = outlineView.selectedRow

        guard let item = outlineView.item(atRow: selectedIndex) as? CEWorkspaceFile else { return }

        if item.children == nil && shouldSendSelectionUpdate {
            DispatchQueue.main.async {
                self.workspace?.tabManager.activeTabGroup.openTab(item: item, asTemporary: true)
            }
        }
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        rowHeight // This can be changed to 20 to match Xcode's row height.
    }

    func outlineViewItemDidExpand(_ notification: Notification) {
        guard
            let id = workspace?.tabManager.activeTabGroup.selected?.id,
            let item = content.find(by: .codeEditor(id))
        else {
            return
        }
        /// update outline selection only if the parent of selected item match with expanded item
        guard item.parent === notification.userInfo?["NSObject"] as? CEWorkspaceFile else {
            return
        }
        /// select active file under collapsed folder only if its parent is expanding
        if outlineView.isItemExpanded(item.parent) {
            updateSelection(itemID: item.id)
        }
    }

    func outlineViewItemDidCollapse(_ notification: Notification) {}

    func outlineView(_ outlineView: NSOutlineView, itemForPersistentObject object: Any) -> Any? {
        guard let id = object as? CEWorkspaceFile.ID,
              let item = try? workspace?.workspaceFileManager?.getFile(id) else { return nil }
        return item
    }

    func outlineView(_ outlineView: NSOutlineView, persistentObjectForItem item: Any?) -> Any? {
        guard let item = item as? CEWorkspaceFile else { return nil }
        return item.id
    }

    /// Recursively gets and selects an ``Item`` from an array of ``Item`` and their `children` based on the `id`.
    /// - Parameters:
    ///   - id: the id of the item item
    ///   - collection: the array to search for
    ///   - forcesReveal: The boolean to indicates whether or not it should force to reveal the selected file.
    private func select(by id: TabBarItemID, from collection: [CEWorkspaceFile], forcesReveal: Bool) {
        guard let item = collection.find(by: id) else {
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
        outlineView.selectRowIndexes(.init(integer: row), byExtendingSelection: false)

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
}
