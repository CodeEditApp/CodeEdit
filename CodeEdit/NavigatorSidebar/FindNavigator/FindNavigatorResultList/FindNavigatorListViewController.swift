//
//  FindNavigatorListViewController.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/7/22.
//

import SwiftUI
import WorkspaceClient
import Search
import AppPreferences

final class FindNavigatorListViewController: NSViewController {

    var searchItems: [SearchResultModel] = []
    var scrollView: NSScrollView!
    var outlineView: NSOutlineView!
    private let prefs = AppPreferencesModel.shared.preferences
    private var collapsedRows: Set<Int> = []

    var rowHeight: Double = 22 {
        didSet {
            outlineView?.reloadData()
        }
    }

    /// Setup the ``scrollView`` and ``outlineView``
    override func loadView() {
        self.scrollView = NSScrollView()
        self.view = scrollView

        self.outlineView = NSOutlineView()
        self.outlineView.dataSource = self
        self.outlineView.delegate = self
        self.outlineView.headerView = nil
//        self.outlineView.usesAutomaticRowHeights = true

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

    public func updateNewSearchResults(_ searchItems: [SearchResultModel]) {
        self.searchItems = searchItems
        self.outlineView.reloadData()
        self.outlineView.expandItem(nil, expandChildren: true)
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
        return item as? SearchResultModel != nil
    }

    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        true
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let tableColumn = tableColumn else { return nil }
        if let item = item as? SearchResultMatchModel {
            let frameRect = NSRect(x: 0, y: 0, width: tableColumn.width, height: CGFloat.greatestFiniteMagnitude)
            return FindNavigatorListMatchCell(frame: frameRect,
                                              matchItem: item)
        } else {
            let frameRect = NSRect(x: 0,
                                   y: 0,
                                   width: tableColumn.width,
                                   height: prefs.general.projectNavigatorSize.rowHeight)
            let view = OutlineTableViewCell(frame: frameRect,
                                            item: (item as? SearchResultModel)?.file,
                                            isEditable: false)
            // We're using a medium label for file names b/c it makes it easier to
            // distinguish quickly which results are from which files.
            view.label.font = .systemFont(ofSize: 13, weight: .medium)
            return view
        }
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        // TODO: Select the file item & line
    }

//    func outlineViewItemDidExpand(_ notification: Notification) {
//        guard let item = notification.object else { return }
//        let row = outlineView.row(forItem: item)
//        if row >= 0 {
//            collapsedRows.remove(row)
//        }
//    }
//
//    func outlineViewItemDidCollapse(_ notification: Notification) {
//        guard let item = notification.object else { return }
//        let row = outlineView.row(forItem: item)
//        if row >= 0 {
//            collapsedRows.insert(row)
//        }
//    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if let item = item as? SearchResultMatchModel,
           let lineContent = item.lineContent,
           let keywordRange = item.keywordRange {
            let lowerIndex = lineContent.index(keywordRange.lowerBound,
                                               offsetBy: -120,
                                               limitedBy: lineContent.startIndex) ?? lineContent.startIndex
            let upperIndex = lineContent.index(keywordRange.upperBound,
                                               offsetBy: 120,
                                               limitedBy: lineContent.endIndex) ?? lineContent.endIndex
            let tempView = NSTextField(wrappingLabelWithString: String(lineContent[lowerIndex..<upperIndex]))
            let width = outlineView.frame.width - outlineView.indentationPerLevel - 22
            return max(tempView.sizeThatFits(NSSize(width: width,
                                                    height: CGFloat.greatestFiniteMagnitude)).height + 8,
                       rowHeight)
        } else {
            return rowHeight
        }
    }

    func outlineViewColumnDidResize(_ notification: Notification) {
        guard let range = Range(outlineView.rows(in: scrollView.visibleRect)) else {
            return
        }
        let indexes = IndexSet(integersIn: range)
        outlineView.noteHeightOfRows(withIndexesChanged: indexes)
    }

}

// MARK: - NSMenuDelegate

extension FindNavigatorListViewController: NSMenuDelegate {

}
