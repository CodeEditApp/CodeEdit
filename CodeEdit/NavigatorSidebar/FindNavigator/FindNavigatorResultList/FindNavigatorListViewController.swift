//
//  FindNavigatorListViewController.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/7/22.
//

import SwiftUI
import WorkspaceClient
import Search

final class FindNavigatorListViewController: NSViewController {

    var searchItems: [SearchResultModel] = []
    var scrollView: NSScrollView!
    var outlineView: NSOutlineView!

    /// Setup the ``scrollView`` and ``outlineView``
    override func loadView() {
        self.scrollView = NSScrollView()
        self.view = scrollView

        self.outlineView = NSOutlineView()
        self.outlineView.dataSource = self
        self.outlineView.delegate = self
        self.outlineView.autosaveExpandedItems = true
        self.outlineView.headerView = nil
        self.outlineView.menu = OutlineMenu(sender: self.outlineView)
        self.outlineView.menu?.delegate = self
        self.outlineView.usesAutomaticRowHeights = true

        let column = NSTableColumn(identifier: .init(rawValue: "Cell"))
        column.title = "Cell"
        outlineView.addTableColumn(column)

        self.scrollView.documentView = outlineView
        self.scrollView.contentView.automaticallyAdjustsContentInsets = false
        self.scrollView.contentView.contentInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) not implemented by FindNavigatorListViewController")
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

    func outlineView(_ outlineView: NSOutlineView,
                     shouldShowCellExpansionFor tableColumn: NSTableColumn?,
                     item: Any) -> Bool {
        true
    }

    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        true
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let tableColumn = tableColumn else { return nil }
        let frameRect = NSRect(x: 0, y: 0, width: tableColumn.width, height: 32)
        print(type(of: item))
        let view = NSView(frame: frameRect)
        return view
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        // TODO: Select the file item & line
    }

}

// MARK: - NSMenuDelegate

extension FindNavigatorListViewController: NSMenuDelegate {

}
