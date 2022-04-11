//
//  OutlineViewController.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 07.04.22.
//

import SwiftUI
import WorkspaceClient
import AppPreferences

/// A `NSViewController` that handles the **ProjectNavigator** in the **NavigatorSideabr**.
///
/// Adds a ``outlineView`` inside a ``scrollView`` which shows the folder structure of the
/// currently open project.
class OutlineViewController: NSViewController {

    typealias Item = WorkspaceClient.FileItem

    var scrollView: NSScrollView!
    var outlineView: NSOutlineView!

    /// Gets the folder structure
    ///
    /// Also creates a top level item "root" which represents the projects root directory and automatically expands it.
    private var content: [Item] {
        guard let folderURL = workspace?.workspaceClient?.folderURL() else { return [] }
        let children = workspace?.selectionState.fileItems.sortItems(foldersOnTop: true)
        guard let root = try? workspace?.workspaceClient?.getFileItem(folderURL.path) else { return [] }
        root.children = children
        return [root]
    }

    var workspace: WorkspaceDocument?

    var iconColor: AppPreferences.FileIconStyle = .color

    var rowHeight: Double = 22 {
        didSet {
            outlineView.rowHeight = rowHeight
            outlineView.reloadData()
        }
    }

    /// Setup the ``scrollView`` and ``outlineView``
    override func loadView() {
        self.scrollView = NSScrollView()
        self.view = scrollView

        self.outlineView = NSOutlineView()
        self.outlineView.dataSource = self
        self.outlineView.delegate = self
        self.outlineView.autosaveExpandedItems = true
        self.outlineView.autosaveName = workspace?.workspaceClient?.folderURL()?.path ?? ""
        self.outlineView.headerView = nil
        self.outlineView.menu = OutlineMenu(sender: self.outlineView)
        self.outlineView.menu?.delegate = self
        self.outlineView.registerForDraggedTypes([.fileURL])

        let column = NSTableColumn(identifier: .init(rawValue: "Cell"))
        column.title = "Cell"
        outlineView.addTableColumn(column)

        self.scrollView.documentView = outlineView
        self.scrollView.contentView.automaticallyAdjustsContentInsets = false
        self.scrollView.contentView.contentInsets = .init(top: 10, left: 0, bottom: 0, right: 0)

        outlineView.expandItem(outlineView.item(atRow: 0))
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    /// Updates the selection of the ``outlineView`` whenever it changes.
    ///
    /// Most importantly when the `id` changes from an external view.
    func updateSelection() {
        guard let itemID = workspace?.selectionState.selectedId else {
            outlineView.deselectRow(outlineView.selectedRow)
            return
        }

        select(by: itemID, from: content)

    }

    /// Get the appropriate color for the items icon depending on the users preferences.
    /// - Parameter item: The `FileItem` to get the color for
    /// - Returns: A `NSColor` for the given `FileItem`.
    private func color(for item: Item) -> NSColor {
        if item.children == nil && iconColor == .color {
            return NSColor(item.iconColor)
        } else {
            return .secondaryLabelColor
        }
    }

}

// MARK: - NSOutlineViewDataSource

extension OutlineViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? Item {
            return item.children?.count ?? 0
        }
        return content.count
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? Item,
           let children = item.children {
            return children[index]
        }
        return content[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? Item {
            return item.children != nil
        }
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        if let item = item as? Item {
            return item.url as NSURL
        }
        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        if index != -1 {
            outlineView.draggingDestinationFeedbackStyle = .regular
        } else {
            outlineView.draggingDestinationFeedbackStyle = .none
        }
        if let _ = item as? Item {
            return .link
        }
        return []
    }
    
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        guard index != -1, let items = info.draggingPasteboard.pasteboardItems, items.count > 0, let movingItem = item as? Item, var itemChildren = movingItem.children else { return false }
        print("itemChildren before: \(itemChildren)")
        let fileNames = items.compactMap { $0.string(forType: .fileURL) }
        var fileNameSet = Set(fileNames)
        let movedItems = itemChildren.filter { !fileNameSet.insert($0.url.absoluteString).inserted }
        itemChildren.insert(contentsOf: movedItems, at: index)
        print("itemChildren after: \(itemChildren)")
        return true
    }
}

// MARK: - NSOutlineViewDelegate

extension OutlineViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView,
                     shouldShowCellExpansionFor tableColumn: NSTableColumn?, item: Any) -> Bool {
        return true
    }

    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        return true
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {

        guard let tableColumn = tableColumn else { return nil }

        let frameRect = NSRect(x: 0, y: 0, width: tableColumn.width, height: rowHeight)

        let view = OutlineTableViewCell(frame: frameRect)

        if let item = item as? Item {
            let image = NSImage(systemSymbolName: item.systemImage, accessibilityDescription: nil)!
            view.icon.image = image
            view.icon.contentTintColor = color(for: item)

            view.label.stringValue = item.fileName
        }

        return view
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else {
            return
        }

        let selectedIndex = outlineView.selectedRow

        guard let item = outlineView.item(atRow: selectedIndex) as? Item else { return }

        if item.children == nil {
            workspace?.openFile(item: item)
        }
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return rowHeight // This can be changed to 20 to match Xcodes row height.
    }

    func outlineViewItemDidExpand(_ notification: Notification) {
        updateSelection()
    }

    func outlineViewItemDidCollapse(_ notification: Notification) {}

    func outlineView(_ outlineView: NSOutlineView, itemForPersistentObject object: Any) -> Any? {
        guard let id = object as? Item.ID,
              let item = try? workspace?.workspaceClient?.getFileItem(id) else { return nil }
        return item
    }

    func outlineView(_ outlineView: NSOutlineView, persistentObjectForItem item: Any?) -> Any? {
        guard let item = item as? Item else { return nil }
        return item.id
    }

    /// Recursively gets and selects an ``Item`` from an array of ``Item`` and their `children` based on the `id`.
    /// - Parameters:
    ///   - id: the id of the item item
    ///   - collection: the array to search for
    private func select(by id: Item.ID, from collection: [Item]) {
        guard let item = collection.first(where: { $0.id == id }) else {
            for item in collection {
                select(by: id, from: item.children ?? [])
            }
            return
        }
        let row = outlineView.row(forItem: item)
        if row == -1 {
            outlineView.deselectRow(outlineView.selectedRow)
        }
        outlineView.selectRowIndexes(.init(integer: row), byExtendingSelection: false)
    }
}

extension OutlineViewController: NSMenuDelegate {

    /// Once a menu gets requested by a `right click` setup the menu
    ///
    /// If the right click happened outside a row this will result in no menu being shown.
    /// - Parameter menu: The menu that got requested
    func menuNeedsUpdate(_ menu: NSMenu) {
        let row = outlineView.clickedRow
        guard let menu = menu as? OutlineMenu else { return }

        if row == -1 {
            menu.item = nil
        } else {
            if let item = outlineView.item(atRow: row) as? Item {
                menu.item = item
            } else {
                menu.item = nil
            }
        }
        menu.update()
    }
}
