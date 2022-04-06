//
//  OutlineViewController.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 07.04.22.
//

import SwiftUI
import WorkspaceClient
import AppPreferences

class OutlineViewController: NSViewController {

    var scrollView: NSScrollView!
    var outlineView: NSOutlineView!

    var content: [WorkspaceClient.FileItem] = []

    var workspace: WorkspaceDocument?

    var iconColor: AppPreferences.FileIconStyle = .color

    override func loadView() {
        self.scrollView = NSScrollView()
        self.view = scrollView

        self.outlineView = NSOutlineView()
        self.outlineView.delegate = self
        self.outlineView.dataSource = self
        self.outlineView.headerView = nil
        self.outlineView.menu = OutlineMenu()
        self.outlineView.menu?.delegate = self

        let column = NSTableColumn(identifier: .init(rawValue: "Cell"))
        column.title = "Cell"
        outlineView.addTableColumn(column)

        self.scrollView.documentView = outlineView
        reloadContent()
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func updateSelection() {
        print("Update")
        guard let itemID = workspace?.selectionState.selectedId,
              let item = try? workspace?.workspaceClient?.getFileItem(itemID) else { return }

        let row = outlineView.row(forItem: item)
        print(item.fileName, row)
        outlineView.selectRowIndexes(.init(integer: row), byExtendingSelection: false)
    }

    private func reloadContent() {
        self.content = workspace?.selectionState.fileItems.sortItems(foldersOnTop: true) ?? []
        outlineView.reloadData()
    }

    private func color(for item: WorkspaceClient.FileItem) -> NSColor {
        if item.children == nil {
            if iconColor == .color {
                return NSColor(item.iconColor)
            } else {
                return .secondaryLabelColor
            }
        } else {
            return .secondaryLabelColor
        }
    }
}

// MARK: - NSOutlineViewDataSource

extension OutlineViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? WorkspaceClient.FileItem {
            return item.children?.count ?? 0
        }
        return content.count
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? WorkspaceClient.FileItem,
           let children = item.children {
            return children[index]
        }
        return content[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? WorkspaceClient.FileItem {
            return item.children != nil
        }
        return false
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

        let frameRect = NSRect(x: 0, y: 0, width: tableColumn.width, height: 20)

        let view = OutlineTableViewCell(frame: frameRect)

        if let item = item as? WorkspaceClient.FileItem {
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

        guard let item = outlineView.item(atRow: selectedIndex) as? WorkspaceClient.FileItem else { return }

        if item.children == nil {
            workspace?.openFile(item: item)
        }
    }
}

extension OutlineViewController: NSMenuDelegate {

    func menuNeedsUpdate(_ menu: NSMenu) {
        let row = outlineView.clickedRow
        guard let menu = menu as? OutlineMenu else { return }

        if row == -1 {
            menu.item = nil
        } else {
            let item = content[row]
            menu.item = item
        }
        menu.update()
    }
}
