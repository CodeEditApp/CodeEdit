//
//  BreadcrumbsMenu.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/29.
//

import AppKit
import WorkspaceClient

class BreadcrumsMenu: NSMenu, NSMenuDelegate {

    let fileItems: [WorkspaceClient.FileItem]
    let workspace: WorkspaceDocument

    init(_ fileItems: [WorkspaceClient.FileItem], workspace: WorkspaceDocument) {
        self.fileItems = fileItems
        self.workspace = workspace
        super.init(title: "")
        self.delegate = self
        fileItems.forEach { item in
            let menuItem = BreadcrumbsMenuItem(item, workspace: workspace)
            self.addItem(menuItem)
        }
        self.autoenablesItems = false
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Only when menu item is highlighted then generate its submenu
    func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        if let highlightedItem = item, let submenuItems = highlightedItem.submenu?.items, submenuItems.isEmpty {
            if let highlightedFileItem = highlightedItem.representedObject as? WorkspaceClient.FileItem {
                highlightedItem.submenu = generateSubmenu(highlightedFileItem)
            }
        }
    }

    private func generateSubmenu(_ fileItem: WorkspaceClient.FileItem) -> BreadcrumsMenu? {
        if let children = fileItem.children {
            let menu = BreadcrumsMenu(children, workspace: workspace)
            return menu
        }
        return nil
    }
}

class BreadcrumbsMenuItem: NSMenuItem {
    let fileItem: WorkspaceClient.FileItem
    var workspace: WorkspaceDocument

    init(_ fileItem: WorkspaceClient.FileItem, workspace: WorkspaceDocument) {
        self.fileItem = fileItem
        self.workspace = workspace
        super.init(title: fileItem.fileName, action: #selector(openFile), keyEquivalent: "")
        var icon = fileItem.fileIcon
        var color = fileItem.iconColor
        self.isEnabled = true
        self.target = self
        if fileItem.children != nil {
            let subMenu = NSMenu()
            self.submenu = subMenu
            icon = "folder.fill"
            color = .secondary
        }
        let image = NSImage(
            systemSymbolName: icon,
            accessibilityDescription: icon
        )?.withSymbolConfiguration(.init(paletteColors: [NSColor(color)]))
        self.image = image
        self.representedObject = fileItem
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func openFile() {
        workspace.openFile(item: fileItem)
    }
}
