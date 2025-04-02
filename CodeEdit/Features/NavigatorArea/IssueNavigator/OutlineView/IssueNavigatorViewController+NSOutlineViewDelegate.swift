//
//  IssueNavigatorViewController+NSOutlineViewDelegate.swift
//  CodeEdit
//
//  Created by Abe Malla on 3/16/25.
//

import AppKit

extension IssueNavigatorViewController: NSOutlineViewDelegate {
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

        if let node = item as? (any IssueNode) {
            return IssueTableViewCell(frame: frameRect, node: node)
        }
        return TextTableViewCell(frame: frameRect, startingText: "Unknown item")
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if let diagnosticNode = item as? DiagnosticIssueNode {
            let columnWidth = outlineView.tableColumns.first?.width ?? outlineView.frame.width
            let indentationLevel = outlineView.level(forItem: item)
            let indentationSpace = CGFloat(indentationLevel) * outlineView.indentationPerLevel
            let availableWidth = columnWidth - indentationSpace - 24

            // Create a temporary text field for measurement
            let tempView = NSTextField(wrappingLabelWithString: diagnosticNode.name)
            tempView.allowsDefaultTighteningForTruncation = false
            tempView.cell?.truncatesLastVisibleLine = true
            tempView.cell?.wraps = true
            tempView.maximumNumberOfLines = Settings.shared.preferences.general.issueNavigatorDetail.rawValue
            tempView.preferredMaxLayoutWidth = availableWidth

            let height = tempView.sizeThatFits(
                NSSize(width: availableWidth, height: CGFloat.greatestFiniteMagnitude)
            ).height
            return max(height + 8, rowHeight)
        }
        return rowHeight
    }

    func outlineViewColumnDidResize(_ notification: Notification) {
        // Disable animations temporarily
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = 0

        let indexes = IndexSet(integersIn: 0..<outlineView.numberOfRows)
        outlineView.noteHeightOfRows(withIndexesChanged: indexes)

        NSAnimationContext.endGrouping()
        outlineView.layoutSubtreeIfNeeded()
    }

    /// Adds a tooltip to the issue row.
    func outlineView( // swiftlint:disable:this function_parameter_count
        _ outlineView: NSOutlineView,
        toolTipFor cell: NSCell,
        rect: NSRectPointer,
        tableColumn: NSTableColumn?,
        item: Any,
        mouseLocation: NSPoint
    ) -> String {
        if let node = item as? (any IssueNode) {
            return node.name
        }
        return ""
    }
}
