//
//  IssueNavigatorViewController+NSMenuDelegate.swift.swift
//  CodeEdit
//
//  Created by Abe Malla on 4/3/25.
//

import AppKit

extension IssueNavigatorViewController: NSMenuDelegate {
    /// Once a menu gets requested by a `right click` setup the menu
    ///
    /// If the right click happened outside a row this will result in no menu being shown.
    /// - Parameter menu: The menu that got requested
    func menuNeedsUpdate(_ menu: NSMenu) {
        let row = outlineView.clickedRow
        guard let menu = menu as? IssueNavigatorMenu else { return }

        if row == -1 {
            menu.item = nil
        } else {
            if let item = outlineView.item(atRow: row) as? (any IssueNode) {
                menu.item = item
                menu.workspace = workspace
            } else {
                menu.item = nil
            }
        }
        menu.update()
    }
}
