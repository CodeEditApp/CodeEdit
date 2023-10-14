//
//  CodeEditWindowControllerExtensions.swift
//  CodeEdit
//
//  Created by Austin Condiff on 10/14/23.
//

import SwiftUI

extension CodeEditWindowController {
    @objc
    func toggleFirstPanel() {
        guard let firstSplitView = splitViewController.splitViewItems.first else { return }
        firstSplitView.animator().isCollapsed.toggle()
        if let codeEditSplitVC = splitViewController as? CodeEditSplitViewController {
            codeEditSplitVC.saveNavigatorCollapsedState(isCollapsed: firstSplitView.isCollapsed)
        }
    }

    @objc
    func toggleLastPanel() {
        guard let lastSplitView = splitViewController.splitViewItems.last else { return }

        if let toolbar = window?.toolbar,
           lastSplitView.isCollapsed,
           !toolbar.items.map(\.itemIdentifier).contains(.itemListTrackingSeparator) {
            window?.toolbar?.insertItem(withItemIdentifier: .itemListTrackingSeparator, at: 4)
        }
        NSAnimationContext.runAnimationGroup { _ in
            lastSplitView.animator().isCollapsed.toggle()
        } completionHandler: { [weak self] in
            if lastSplitView.isCollapsed {
                self?.window?.animator().toolbar?.removeItem(at: 4)
            }
        }

        if let codeEditSplitVC = splitViewController as? CodeEditSplitViewController {
            codeEditSplitVC.saveInspectorCollapsedState(isCollapsed: lastSplitView.isCollapsed)
            codeEditSplitVC.hideInspectorToolbarBackground()
        }
    }

    /// These are example items that added as commands to command palette
    func registerCommands() {
        CommandManager.shared.addCommand(
            name: "Quick Open",
            title: "Quick Open",
            id: "quick_open",
            command: CommandClosureWrapper(closure: { self.openQuickly(self) })
        )

        CommandManager.shared.addCommand(
            name: "Toggle Navigator",
            title: "Toggle Navigator",
            id: "toggle_left_sidebar",
            command: CommandClosureWrapper(closure: { self.toggleFirstPanel() })
        )

        CommandManager.shared.addCommand(
            name: "Toggle Inspector",
            title: "Toggle Inspector",
            id: "toggle_right_sidebar",
            command: CommandClosureWrapper(closure: { self.toggleLastPanel() })
        )
    }
}

extension NSToolbarItem.Identifier {
    static let toggleFirstSidebarItem: NSToolbarItem.Identifier = NSToolbarItem.Identifier("ToggleFirstSidebarItem")
    static let toggleLastSidebarItem: NSToolbarItem.Identifier = NSToolbarItem.Identifier("ToggleLastSidebarItem")
    static let itemListTrackingSeparator = NSToolbarItem.Identifier("ItemListTrackingSeparator")
    static let branchPicker: NSToolbarItem.Identifier = NSToolbarItem.Identifier("BranchPicker")
}
