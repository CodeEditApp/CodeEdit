//
//  OutlineMenu.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 07.04.22.
//

import SwiftUI
import WorkspaceClient

class OutlineMenu: NSMenu {

    var item: WorkspaceClient.FileItem?

    init() {
        super.init(title: "Options")
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func menuItem(_ title: String, action: Selector?, key: String = "") -> NSMenuItem {
        let mItem = NSMenuItem(title: title, action: action, keyEquivalent: key)
        mItem.target = self

        return mItem
    }

    private func setupMenu(isFile: Bool) {
        let showInFinder = menuItem("Show in Finder", action: #selector(showInFinder))

        let openInTab = menuItem("Open in Tab", action: nil)
        let openInNewWindow = menuItem("Open in New Window", action: nil)
        let openExternalEditor = menuItem("Open with External Editor", action: nil)
        let openAs = menuItem("Open As", action: nil)

        let showFileInspector = menuItem("Show File Inspector", action: nil)

        let newFile = menuItem("New File...", action: nil)
        let newFolder = menuItem("New Folder", action: nil)

        let delete = menuItem("Delete", action: #selector(delete))

        let sortByName = menuItem("Sort by Name", action: nil)
        sortByName.isEnabled = !isFile

        let sortByType = menuItem("Sort by Type", action: nil)
        sortByType.isEnabled = !isFile

        let sourceControl = menuItem("Source Control", action: nil)

        self.items = [
            showInFinder,
            NSMenuItem.separator(),
            openInTab,
            openInNewWindow,
            openExternalEditor,
            openAs,
            NSMenuItem.separator(),
            showFileInspector,
            NSMenuItem.separator(),
            newFile,
            newFolder,
            NSMenuItem.separator(),
            delete,
            NSMenuItem.separator(),
            sortByName,
            sortByType,
            NSMenuItem.separator(),
            sourceControl,
        ]

        self.setSubmenu(openAsMenu(), for: openAs)
        self.setSubmenu(sourceControlMenu(), for: sourceControl)
    }

    private func openAsMenu() -> NSMenu {
        let openAsMenu = NSMenu(title: "Open As")
        openAsMenu.addItem(withTitle: "Source Core", action: nil, keyEquivalent: "")
        openAsMenu.addItem(.separator())
        openAsMenu.addItem(withTitle: "ASCII Property List", action: nil, keyEquivalent: "")
        openAsMenu.addItem(withTitle: "Hex", action: nil, keyEquivalent: "")
        openAsMenu.addItem(withTitle: "Quick Look", action: nil, keyEquivalent: "")

        return openAsMenu
    }

    private func sourceControlMenu() -> NSMenu {
        let sourceControlMenu = NSMenu(title: "Source Control")
        sourceControlMenu.addItem(withTitle: "Commit...", action: nil, keyEquivalent: "")
        sourceControlMenu.addItem(.separator())
        sourceControlMenu.addItem(withTitle: "Discard Changes...", action: nil, keyEquivalent: "")
        sourceControlMenu.addItem(.separator())
        sourceControlMenu.addItem(withTitle: "Add Selected Files", action: nil, keyEquivalent: "")
        sourceControlMenu.addItem(withTitle: "Mark Selected Files as Resolved", action: nil, keyEquivalent: "")

        return sourceControlMenu
    }

    override func update() {
        self.removeAllItems()
        if let item = item {
            setupMenu(isFile: item.children == nil)
        }
    }

    @objc
    private func showInFinder() {
        if let item = item {
            item.showInFinder()
        }
    }

    @objc
    private func delete() {
        if let item = item {
            item.delete()
        }
    }
}
