//
//  PathBarMenu.swift
//  CodeEditModules/PathBar
//
//  Created by Ziyuan Zhao on 2022/3/29.
//

import AppKit

final class PathBarMenu: NSMenu, NSMenuDelegate {
    private let fileItems: [CEWorkspaceFile]
    private let tappedOpenFile: (CEWorkspaceFile) -> Void

    init(
        fileItems: [CEWorkspaceFile],
        tappedOpenFile: @escaping (CEWorkspaceFile) -> Void
    ) {
        self.fileItems = fileItems
        self.tappedOpenFile = tappedOpenFile
        super.init(title: "")
        delegate = self
        fileItems.forEach { item in
            let menuItem = PathBarMenuItem(
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
            if let highlightedFileItem = highlightedItem.representedObject as? CEWorkspaceFile {
                highlightedItem.submenu = generateSubmenu(highlightedFileItem)
            }
        }
    }

    private func generateSubmenu(_ fileItem: CEWorkspaceFile) -> PathBarMenu? {
        if let children = fileItem.children {
            let menu = PathBarMenu(
                fileItems: children,
                tappedOpenFile: tappedOpenFile
            )
            return menu
        }
        return nil
    }
}

final class PathBarMenuItem: NSMenuItem {
    private let fileItem: CEWorkspaceFile
    private let tappedOpenFile: (CEWorkspaceFile) -> Void

    init(
        fileItem: CEWorkspaceFile,
        tappedOpenFile: @escaping (CEWorkspaceFile) -> Void
    ) {
        self.fileItem = fileItem
        self.tappedOpenFile = tappedOpenFile
        super.init(title: fileItem.name, action: #selector(openFile), keyEquivalent: "")

        var icon = fileItem.systemImage
        var color = NSColor(fileItem.iconColor)
        isEnabled = true
        target = self
        if fileItem.children != nil {
            let subMenu = NSMenu()
            submenu = subMenu
            icon = fileItem.systemImage
            color = NSColor(named: "FolderBlue") ?? NSColor(.secondary)
        }
        let image = NSImage(
            systemSymbolName: icon,
            accessibilityDescription: icon
        )?.withSymbolConfiguration(.init(paletteColors: [color]))
        self.image = image
        representedObject = fileItem
        if fileItem.isFolder {
            self.action = nil
        }
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    func openFile() {
        tappedOpenFile(fileItem)
    }
}
