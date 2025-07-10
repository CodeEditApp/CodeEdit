//
//  IssueNavigatorMenu.swift
//  CodeEdit
//
//  Created by Abe Malla on 4/3/25.
//

import SwiftUI

final class IssueNavigatorMenu: NSMenu {
    var item: (any IssueNode)?

    /// The workspace, for opening the item
    var workspace: WorkspaceDocument?

    /// The  `IssueNavigatorViewController` is being called from.
    /// By sending it, we can access it's variables and functions.
    var sender: IssueNavigatorViewController

    init(_ sender: IssueNavigatorViewController) {
        self.sender = sender
        super.init(title: "Options")
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Creates a `NSMenuItem` depending on the given arguments
    /// - Parameters:
    ///   - title: The title of the menu item
    ///   - action: A `Selector` or `nil` of the action to perform.
    ///   - key: A `keyEquivalent` of the menu item. Defaults to an empty `String`
    /// - Returns: A `NSMenuItem` which has the target `self`
    private func menuItem(_ title: String, action: Selector?, key: String = "") -> NSMenuItem {
        let mItem = NSMenuItem(title: title, action: action, keyEquivalent: key)
        mItem.target = self
        return mItem
    }

    /// Configures the menu based on the current selection in the outline view.
    /// - Menu items get added depending on the amount of selected items.
    private func setupMenu() {
        guard item != nil else { return }

        let copy = menuItem("Copy", action: #selector(copyIssue))
        let showInFinder = menuItem("Show in Finder", action: #selector(showInFinder))
        let revealInProjectNavigator = menuItem(
            "Reveal in Project Navigator",
            action: #selector(revealInProjectNavigator)
        )
        let openInTab = menuItem("Open in Tab", action: #selector(openInTab))
        let openWithExternalEditor = menuItem("Open with External Editor", action: #selector(openWithExternalEditor))

        items = [
            copy,
            .separator(),
            showInFinder,
            revealInProjectNavigator,
            .separator(),
            openInTab,
            openWithExternalEditor,
        ]
    }

    /// Updates the menu for the selected item and hides it if no item is provided.
    override func update() {
        removeAllItems()
        setupMenu()
    }
}
