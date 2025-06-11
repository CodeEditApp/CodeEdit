//
//  ProjectNavigatorViewController+NSMenuDelegate.swift
//  CodeEdit
//
//  Created by Dscyre Scotti on 6/23/23.
//

import SwiftUI

// MARK: - NSMenuDelegate
extension ProjectNavigatorViewController: NSMenuDelegate {

    /// Once a menu gets requested by a `right click` setup the menu
    ///
    /// If the right click happened outside a row this will result in no menu being shown.
    /// - Parameter menu: The menu that got requested
    func menuNeedsUpdate(_ menu: NSMenu) {
        let row = outlineView.clickedRow
        guard let menu = menu as? ProjectNavigatorMenu else { return }

        menu.workspace = workspace
        if row == -1 {
            menu.item = nil
        } else {
            if let item = outlineView.item(atRow: row) as? CEWorkspaceFile {
                menu.item = item
            } else {
                menu.item = nil
            }
        }
        menu.update()
    }
}
