//
//  QuickLookPreviewController.swift
//  CodeEdit
//
//  Created by Leonardo Larrañaga on 7/10/24.
//

import QuickLookUI
import SwiftUI

/// A class that handles file preview using Quick Look.
class QuickLookPreviewController: NSObject, QLPreviewPanelDataSource, QLPreviewPanelDelegate {
    /// Shared instance of `QuickLookPreviewController` for global use.
    static let shared = QuickLookPreviewController()

    /// URL of the item to preview.
    static var previewItemURL: URL!

    /// Returns the number of items to preview in the Quick Look panel.
    /// Requiered function for `QLPreviewPanelDelegate`.
    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        return 1
    }

    /// Returns the item to preview at the specified index.
    /// Requiered function for `QLPreviewPanelDelegate`.
    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> (any QLPreviewItem)! {
        return QuickLookPreviewController.previewItemURL as QLPreviewItem
    }

    /// Opens the Quick Look panel to preview the current item.
    @objc
    func openQuickLookModal() {
        if let previewPanel = QLPreviewPanel.shared() {
            previewPanel.dataSource = self
            previewPanel.delegate = self
            previewPanel.makeKeyAndOrderFront(nil)
        }
    }

    /// Opens the item in a Quick Look tab.
    @objc
    func openQuickLookTab(_ sender: NSMenuItem) {
        guard let context = sender.representedObject as? (CEWorkspaceFile, WorkspaceDocument?) else { return }
        let (item, workspace) = context

        item.isOpeningInQuickLook = true
        workspace?.editorManager.openTab(item: item)
    }

    /// Creates a Quick Look menu for the specified item.
    /// - Parameter item: The workspace file (`CEWorkspaceFile`) for which the menu item will be created.
    /// - Returns: A menu item configured to open Quick Look.
    static func quickLookMenu(item: CEWorkspaceFile, workspace: WorkspaceDocument?) -> NSMenuItem {
        QuickLookPreviewController.previewItemURL = item.url

        let openInModalMenuItem = NSMenuItem(
            title: "Open in Modal",
            action: #selector(QuickLookPreviewController.shared.openQuickLookModal),
            keyEquivalent: ""
        )
        openInModalMenuItem.target = QuickLookPreviewController.shared

        let openInTabMenuItem = NSMenuItem(
            title: "Open in Tab",
            action: #selector(QuickLookPreviewController.shared.openQuickLookTab(_:)),
            keyEquivalent: ""
        )
        openInTabMenuItem.target = QuickLookPreviewController.shared
        openInTabMenuItem.representedObject = (item, workspace)

        /// Creating an `NSMenu` then an  `NSMenuItem` so it can be used in `secondaryItems` at  `ProjectNavigatorMenu`.
        let submenu = NSMenu(title: "Quick Look")
        submenu.addItem(openInModalMenuItem)
        submenu.addItem(openInTabMenuItem)

        let menuItem = NSMenuItem(title: "Quick Look", action: nil, keyEquivalent: "")
        menuItem.submenu = submenu

        return menuItem
    }
}
