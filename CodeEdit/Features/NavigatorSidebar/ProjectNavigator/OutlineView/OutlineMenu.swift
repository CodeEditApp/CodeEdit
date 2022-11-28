//
//  OutlineMenu.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 07.04.22.
//

import SwiftUI
import UniformTypeIdentifiers

/// A subclass of `NSMenu` implementing the contextual menu for the project navigator
final class OutlineMenu: NSMenu {
    typealias Item = WorkspaceClient.FileItem

    /// The item to show the contextual menu for
    var item: Item?

    /// The workspace, for opening the item
    var workspace: WorkspaceDocument?

    var outlineView: NSOutlineView

    init(sender: NSOutlineView) {
        outlineView = sender
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

    /// Setup the menu and disables certain items when `isFile` is false
    /// - Parameter isFile: A flag indicating that the item is a file instead of a directory
    private func setupMenu() {
        guard let item = item else { return }
        let showInFinder = menuItem("Show in Finder", action: #selector(showInFinder))

        let openInTab = menuItem("Open in Tab", action: #selector(openInTab))
        let openInNewWindow = menuItem("Open in New Window", action: nil)
        let openExternalEditor = menuItem("Open with External Editor", action: #selector(openWithExternalEditor))
        let openAs = menuItem("Open As", action: nil)

        let showFileInspector = menuItem("Show File Inspector", action: nil)

        let newFile = menuItem("New File...", action: #selector(newFile))
        let newFolder = menuItem("New Folder", action: #selector(newFolder))

        let rename = menuItem("Rename", action: #selector(renameFile))
        let delete = menuItem("Delete", action:
                                item.url != workspace?.workspaceClient?.folderURL()
                              ? #selector(delete) : nil)

        let duplicate = menuItem("Duplicate \(item.isFolder ? "Folder" : "File")", action: #selector(duplicate))

        let sortByName = menuItem("Sort by Name", action: nil)
        sortByName.isEnabled = item.isFolder

        let sortByType = menuItem("Sort by Type", action: nil)
        sortByType.isEnabled = item.isFolder

        let sourceControl = menuItem("Source Control", action: nil)

        items = [
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
            rename,
            delete,
            duplicate,
            NSMenuItem.separator(),
            sortByName,
            sortByType,
            NSMenuItem.separator(),
            sourceControl,
        ]

        setSubmenu(openAsMenu(item: item), for: openAs)
        setSubmenu(sourceControlMenu(item: item), for: sourceControl)
    }

    /// Submenu for **Open As** menu item.
    private func openAsMenu(item: Item) -> NSMenu {
        let openAsMenu = NSMenu(title: "Open As")
        func getMenusItems() -> ([NSMenuItem], [NSMenuItem]) {
            // Use UTType to distinguish between bundle file and user-browsable directory
            // The isDirectory property is not accurate on this.
            guard let type = item.contentType else { return ([.none()], []) }
            if type.conforms(to: .folder) {
                return ([.none()], [])
            }
            var primaryItems = [NSMenuItem]()
            if type.conforms(to: .sourceCode) {
                primaryItems.append(.sourceCode())
            }
            if type.conforms(to: .propertyList) {
                primaryItems.append(.propertyList())
            }
            if type.conforms(to: UTType(filenameExtension: "xcassets")!) {
                primaryItems.append(NSMenuItem(title: "Asset Catalog Document", action: nil, keyEquivalent: ""))
            }
            if type.conforms(to: UTType(filenameExtension: "xib")!) {
                primaryItems.append(NSMenuItem(title: "Interface Builder XIB Document", action: nil, keyEquivalent: ""))
            }
            if type.conforms(to: UTType(filenameExtension: "xcodeproj")!) {
                primaryItems.append(NSMenuItem(title: "Xcode Project", action: nil, keyEquivalent: ""))
            }
            var secondaryItems = [NSMenuItem]()
            if type.conforms(to: .text) {
                secondaryItems.append(.asciiPropertyList())
                secondaryItems.append(.hex())
            }

            // FIXME: Update the quickLook condition
            if type.conforms(to: .data) {
                secondaryItems.append(.quickLook())
            }

            return (primaryItems, secondaryItems)
        }
        let (primaryItems, secondaryItems) = getMenusItems()
        for item in primaryItems {
            openAsMenu.addItem(item)
        }
        if !secondaryItems.isEmpty {
            openAsMenu.addItem(.separator())
        }
        for item in secondaryItems {
            openAsMenu.addItem(item)
        }
        return openAsMenu
    }

    /// Submenu for **Source Control** menu item.
    private func sourceControlMenu(item: Item) -> NSMenu {
        let sourceControlMenu = NSMenu(title: "Source Control")
        sourceControlMenu.addItem(withTitle: "Commit \"\(item.fileName)\"...", action: nil, keyEquivalent: "")
        sourceControlMenu.addItem(.separator())
        sourceControlMenu.addItem(withTitle: "Discard Changes...", action: nil, keyEquivalent: "")
        sourceControlMenu.addItem(.separator())
        sourceControlMenu.addItem(withTitle: "Add Selected Files", action: nil, keyEquivalent: "")
        sourceControlMenu.addItem(withTitle: "Mark Selected Files as Resolved", action: nil, keyEquivalent: "")

        return sourceControlMenu
    }

    /// Updates the menu for the selected item and hides it if no item is provided.
    override func update() {
        removeAllItems()
        setupMenu()
    }

    /// Action that opens **Finder** at the items location.
    @objc
    private func showInFinder() {
        item?.showInFinder()
    }

    /// Action that opens the item, identical to clicking it.
    @objc
    private func openInTab() {
        if let item = item {
            workspace?.openTab(item: item)
        }
    }

    /// Action that opens in an external editor
    @objc
    private func openWithExternalEditor() {
        item?.openWithExternalEditor()
    }

    // TODO: allow custom file names
    /// Action that creates a new untitled file
    @objc
    private func newFile() {
        item?.addFile(fileName: "untitled")
        outlineView.expandItem((item?.isFolder ?? true) ? item : item?.parent)
    }

    // TODO: allow custom folder names
    /// Action that creates a new untitled folder
    @objc
    private func newFolder() {
        item?.addFolder(folderName: "untitled")
        outlineView.expandItem(item)
        outlineView.expandItem((item?.isFolder ?? true) ? item : item?.parent)
    }

    /// Opens the rename file dialogue on the cell this was presented from.
    @objc
    private func renameFile() {
        let row = outlineView.row(forItem: item)
        guard row > 0,
              let cell = outlineView.view(atColumn: 0, row: row, makeIfNecessary: false) as? OutlineTableViewCell else {
            return
        }
        outlineView.window?.makeFirstResponder(cell.textField)
    }

    /// Action that deletes the item.
    @objc
    private func delete() {
        item?.delete()
    }

    /// Action that duplicates the item
    @objc
    private func duplicate() {
        item?.duplicate()
    }
}

extension NSMenuItem {
    fileprivate static func none() -> NSMenuItem {
        let item = NSMenuItem(title: "<None>", action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }

    fileprivate static func sourceCode() -> NSMenuItem {
        NSMenuItem(title: "Source Code", action: nil, keyEquivalent: "")
    }

    fileprivate static func propertyList() -> NSMenuItem {
        NSMenuItem(title: "Property List", action: nil, keyEquivalent: "")
    }

    fileprivate static func asciiPropertyList() -> NSMenuItem {
        NSMenuItem(title: "ASCII Property List", action: nil, keyEquivalent: "")
    }

    fileprivate static func hex() -> NSMenuItem {
        NSMenuItem(title: "Hex", action: nil, keyEquivalent: "")
    }

    fileprivate static func quickLook() -> NSMenuItem {
        NSMenuItem(title: "Quick Look", action: nil, keyEquivalent: "")
    }
}
