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
            let cell = IssueTableViewCell(frame: frameRect, node: node)
            return cell
        }

        let cell = TextTableViewCell(frame: frameRect, startingText: "Unknown item")
        return cell
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if item is DiagnosticIssueNode {
            // TODO: DIAGNOSTIC CELLS SHOULD MIGHT SPAN MULTIPLE ROWS, SO SHOW MULTIPLE LINES
            let lines = Double(Settings.shared.preferences.general.issueNavigatorDetail.rawValue)
            return rowHeight * lines
        }
        return rowHeight // This can be changed to 20 to match Xcode's row height.
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
