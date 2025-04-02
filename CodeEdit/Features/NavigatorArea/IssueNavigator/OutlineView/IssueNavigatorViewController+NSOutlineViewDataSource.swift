//
//  IssueNavigatorViewController+NSOutlineViewDataSource.swift
//  CodeEdit
//
//  Created by Abe Malla on 3/16/25.
//

import AppKit

extension IssueNavigatorViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            // Always show the project node
            return 1
        }
        if let node = item as? ProjectIssueNode {
            return node.files.count
        }
        if let node = item as? FileIssueNode {
            return node.diagnostics.count
        }
        return 0
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return workspace?.issueNavigatorViewModel?.filteredRootNode as Any
        }
        if let node = item as? ProjectIssueNode {
            return node.files[index]
        }
        if let node = item as? FileIssueNode {
            return node.diagnostics[index]
        }

        fatalError("Unexpected item type in IssueNavigator outlineView")
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let node = item as? any IssueNode {
            return node.isExpandable
        }
        return false
    }

    func outlineView(
        _ outlineView: NSOutlineView,
        objectValueFor tableColumn: NSTableColumn?,
        byItem item: Any?
    ) -> Any? {
        return item
    }
}
