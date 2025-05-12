//
//  FindNavigatorListViewController.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/7/22.
//

import SwiftUI

final class FindNavigatorListViewController: NSViewController {

    public var workspace: WorkspaceDocument
    public var selectedItem: Any?

    private var searchItems: [SearchResultModel] = []
    private var scrollView: NSScrollView!
    private var outlineView: NSOutlineView!
    private let prefs = Settings.shared.preferences
    private var collapsedRows: Set<Int> = []

    var rowHeight: Double = 22 {
        didSet {
            outlineView?.reloadData()
        }
    }

    /// Setup the `scrollView` and `outlineView`
    override func loadView() {
        self.scrollView = NSScrollView()
        self.view = scrollView

        self.outlineView = NSOutlineView()
        self.outlineView.dataSource = self
        self.outlineView.delegate = self
        self.outlineView.headerView = nil
        self.outlineView.lineBreakMode = .byTruncatingTail

        let column = NSTableColumn(identifier: .init(rawValue: "Cell"))
        column.title = "Cell"
        outlineView.addTableColumn(column)

        self.scrollView.documentView = outlineView
        self.scrollView.contentView.automaticallyAdjustsContentInsets = false
        self.scrollView.contentView.contentInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
    }

    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) not implemented by FindNavigatorListViewController")
    }

    override var acceptsFirstResponder: Bool { true }

    /// Sets the search items for the view without loading anything.
    /// - Parameter searchItems: The search items to set.
    public func setSearchResults(_ searchItems: [SearchResultModel]) {
        self.searchItems = searchItems
    }

    /// Updates the view with new search results and updates the UI.
    /// - Parameter searchItems: The search items to set.
    public func updateNewSearchResults(_ searchItems: [SearchResultModel]) {
        self.searchItems = searchItems
        outlineView.reloadData()
        outlineView.expandItem(nil, expandChildren: true)

        if let selectedItem {
            selectSearchResult(selectedItem)
        }
    }

    override func keyUp(with event: NSEvent) {
        if event.charactersIgnoringModifiers == String(NSEvent.SpecialKey.delete.unicodeScalar) {
            deleteSelectedItem()
        }
        super.keyUp(with: event)
    }

    /// Removes the selected item, called in response to an action like the backspace
    /// character
    private func deleteSelectedItem() {
        let selectedRow = outlineView.selectedRow
        guard selectedRow >= 0,
              let selectedItem = outlineView.item(atRow: selectedRow) else { return }

        if selectedItem is SearchResultMatchModel {
            guard let parent = outlineView.parent(forItem: selectedItem) else { return }

            // Remove the item from the search results
            let parentIndex = outlineView.childIndex(forItem: parent)
            let childIndex = outlineView.childIndex(forItem: selectedItem)
            searchItems[parentIndex].lineMatches.remove(at: childIndex)

            // If this was the last child, we need to remove the parent or we'll
            // hit an exception
            if searchItems[parentIndex].lineMatches.isEmpty {
                searchItems.remove(at: parentIndex)
                outlineView.removeItems(at: IndexSet([parentIndex]), inParent: nil)
            } else {
                outlineView.removeItems(at: IndexSet([childIndex]), inParent: parent)
            }
        } else {
            let index = outlineView.childIndex(forItem: selectedItem)
            searchItems.remove(at: index)
            outlineView.removeItems(at: IndexSet([index]), inParent: nil)
        }

        outlineView.selectRowIndexes(IndexSet([selectedRow]), byExtendingSelection: false)
    }

    public func selectSearchResult(_ selectedItem: Any) {
        let index = outlineView.row(forItem: selectedItem)
        guard index >= 0 && index != outlineView.selectedRow else { return }
        outlineView.selectRowIndexes(IndexSet([index]), byExtendingSelection: false)
    }
}

// MARK: - NSOutlineViewDataSource

extension FindNavigatorListViewController: NSOutlineViewDataSource {

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? SearchResultModel {
            return item.lineMatches.count
        }
        return searchItems.count
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? SearchResultModel {
            return item.lineMatches[index]
        }
        return searchItems[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if item is SearchResultModel {
            return true
        }
        return false
    }

}

// MARK: - NSOutlineViewDelegate

extension FindNavigatorListViewController: NSOutlineViewDelegate {

    func outlineView(
        _ outlineView: NSOutlineView,
        shouldShowCellExpansionFor tableColumn: NSTableColumn?,
        item: Any
    ) -> Bool {
        item is SearchResultModel
    }

    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        true
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let tableColumn else { return nil }
        if let item = item as? SearchResultMatchModel {
            let frameRect = NSRect(x: 0, y: 0, width: tableColumn.width, height: outlineView.rowHeight)
            return FindNavigatorListMatchCell(frame: frameRect, matchItem: item)
        } else {
            let frameRect = NSRect(
                x: 0,
                y: 0,
                width: tableColumn.width,
                height: prefs.general.projectNavigatorSize.rowHeight
            )
            let view = ProjectNavigatorTableViewCell(
                frame: frameRect,
                item: (item as? SearchResultModel)?.file,
                isEditable: false
            )
            // We're using a medium label for file names b/c it makes it easier to
            // distinguish quickly which results are from which files.
            view.textField?.font = .systemFont(ofSize: 13, weight: .medium)
            return view
        }
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else {
            return
        }

        let selectedIndex = outlineView.selectedRow

        if let item = outlineView.item(atRow: selectedIndex) as? SearchResultMatchModel {
            let selectedMatch = self.selectedItem as? SearchResultMatchModel
            if selectedItem == nil || selectedMatch != item {
                self.selectedItem = item
                workspace.editorManager?.openTab(item: item.file)
            }
        } else if let item = outlineView.item(atRow: selectedIndex) as? SearchResultModel {
            let selectedFile = self.selectedItem as? SearchResultModel
            if selectedItem == nil || selectedFile != item {
                self.selectedItem = item
                workspace.editorManager?.openTab(item: item.file)
            }
        }
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if let matchItem = item as? SearchResultMatchModel {
            guard let column = outlineView.tableColumns.first else {
                return rowHeight
            }
            let columnWidth = column.width
            let indentationLevel = outlineView.level(forItem: item)
            let indentationSpace = CGFloat(indentationLevel) * outlineView.indentationPerLevel
            let horizontalPaddingAndFixedElements: CGFloat = 24.0

            let availableWidth = columnWidth - indentationSpace - horizontalPaddingAndFixedElements

            guard availableWidth > 0 else {
                // Not enough space to display anything, return minimum height
                return max(rowHeight, Settings.shared.preferences.general.projectNavigatorSize.rowHeight)
            }

            let attributedString = matchItem.attributedLabel()

            let tempView = NSTextField()
            tempView.allowsEditingTextAttributes = true
            tempView.attributedStringValue = attributedString

            tempView.isEditable = false
            tempView.isBordered = false
            tempView.drawsBackground = false
            tempView.alignment = .natural

            tempView.cell?.wraps = true
            tempView.cell?.usesSingleLineMode = false
            tempView.lineBreakMode = .byWordWrapping
            tempView.maximumNumberOfLines = Settings.shared.preferences.general.findNavigatorDetail.rawValue
            tempView.preferredMaxLayoutWidth = availableWidth

            var calculatedHeight = tempView.sizeThatFits(
                NSSize(width: availableWidth, height: .greatestFiniteMagnitude)
            ).height

            // Total vertical padding (top + bottom) within the cell around the text
            let verticalPaddingInCell: CGFloat = 8.0
            calculatedHeight += verticalPaddingInCell
            return max(calculatedHeight, self.rowHeight)
        }
        // For parent items
        return prefs.general.projectNavigatorSize.rowHeight
    }

    func outlineViewColumnDidResize(_ notification: Notification) {
        // Disable animations temporarily
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = 0

        var rowsToUpdate = IndexSet()
        for row in 0..<outlineView.numberOfRows {
            if let item = outlineView.item(atRow: row), item is SearchResultMatchModel {
                rowsToUpdate.insert(row)
            }
        }
        if !rowsToUpdate.isEmpty {
            outlineView.noteHeightOfRows(withIndexesChanged: rowsToUpdate)
        }

        NSAnimationContext.endGrouping()
        outlineView.layoutSubtreeIfNeeded()
    }
}

// MARK: - NSMenuDelegate

extension FindNavigatorListViewController: NSMenuDelegate {

}
