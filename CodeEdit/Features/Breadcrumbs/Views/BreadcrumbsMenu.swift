//
//  BreadcrumbsMenu.swift
//  CodeEditModules/Breadcrumbs
//
//  Created by Ziyuan Zhao on 2022/3/29.
//

import AppKit

final class BreadcrumsMenu: NSMenu, NSMenuDelegate {
    private let fileItems: [WorkspaceClient.FileItem]
    private let tappedOpenFile: (WorkspaceClient.FileItem) -> Void

    init(
        fileItems: [WorkspaceClient.FileItem],
        tappedOpenFile: @escaping (WorkspaceClient.FileItem) -> Void
    ) {
        self.fileItems = fileItems
        self.tappedOpenFile = tappedOpenFile
        super.init(title: "")
        delegate = self
        fileItems.forEach { item in
            let menuItem = BreadcrumbsMenuItem(
                fileItem: item
            ) { item in
                tappedOpenFile(item)
            }
            self.addItem(menuItem)
        }
        autoenablesItems = false
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Only when menu item is highlighted then generate its submenu
    func menu(_: NSMenu, willHighlight item: NSMenuItem?) {
        if let highlightedItem = item, let submenuItems = highlightedItem.submenu?.items, submenuItems.isEmpty {
            if let highlightedFileItem = highlightedItem.representedObject as? WorkspaceClient.FileItem {
                highlightedItem.submenu = generateSubmenu(highlightedFileItem)
            }
        }
    }

    private func generateSubmenu(_ fileItem: WorkspaceClient.FileItem) -> BreadcrumsMenu? {
        if let children = fileItem.children {
            let menu = BreadcrumsMenu(
                fileItems: children,
                tappedOpenFile: tappedOpenFile
            )
            return menu
        }
        return nil
    }
}

final class BreadcrumbsMenuItem: NSMenuItem {
    private let fileItem: WorkspaceClient.FileItem
    private let tappedOpenFile: (WorkspaceClient.FileItem) -> Void

    init(
        fileItem: WorkspaceClient.FileItem,
        tappedOpenFile: @escaping (WorkspaceClient.FileItem) -> Void
    ) {
        self.fileItem = fileItem
        self.tappedOpenFile = tappedOpenFile
        super.init(title: fileItem.fileName, action: #selector(openFile), keyEquivalent: "")

        var icon = fileItem.systemImage
        var color = fileItem.iconColor
        isEnabled = true
        target = self
        if fileItem.children != nil {
            let subMenu = NSMenu()
            submenu = subMenu
            icon = "folder.fill"
            color = .secondary
        }
        let image = NSImage(
            systemSymbolName: icon,
            accessibilityDescription: icon
        )?.withSymbolConfiguration(.init(paletteColors: [NSColor(color)]))
        self.image = image
        representedObject = fileItem
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func openFile() {
        tappedOpenFile(fileItem)
    }
}
