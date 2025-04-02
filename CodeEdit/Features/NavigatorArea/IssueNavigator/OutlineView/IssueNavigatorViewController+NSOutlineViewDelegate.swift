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
        let cell = StandardTableViewCell(frame: frameRect)
        if let node = item as? (any IssueNode) {
            cell.configLabel(
                    label: NSTextField(string: node.name),
                    isEditable: false
                )
        }
        return cell
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if item is DiagnosticIssueNode {
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
