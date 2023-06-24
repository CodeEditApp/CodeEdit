//
//  PathBarMenu.swift
//  CodeEditModules/PathBar
//
//  Created by Ziyuan Zhao on 2022/3/29.
//

import AppKit

final class PathBarMenu: NSMenu, NSMenuDelegate {
    typealias Item = any Resource

    private let fileItems: [Item]
    private let tappedOpenFile: (File) -> Void

    init(
        fileItems: [Item],
        tappedOpenFile: @escaping (File) -> Void
    ) {
        self.fileItems = fileItems
        self.tappedOpenFile = tappedOpenFile
        super.init(title: "")
        delegate = self
        fileItems.forEach { item in
            let menuItem = PathBarMenuItem(fileItem: item, tappedOpenFile: tappedOpenFile)
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
            if let highlightedFileItem = highlightedItem.representedObject as? Folder {
                highlightedItem.submenu = generateSubmenu(highlightedFileItem)
            }
        }
    }

    private func generateSubmenu(_ fileItem: Folder) -> PathBarMenu {
        PathBarMenu(
            fileItems: fileItem.children,
            tappedOpenFile: tappedOpenFile
        )
    }
}

final class PathBarMenuItem: NSMenuItem {

    private let fileItem: PathBarMenu.Item
    private let tappedOpenFile: (File) -> Void

    init(
        fileItem: PathBarMenu.Item,
        tappedOpenFile: @escaping (File) -> Void
    ) {
        self.fileItem = fileItem
        self.tappedOpenFile = tappedOpenFile
        super.init(title: fileItem.name, action: #selector(openFile), keyEquivalent: "")

        isEnabled = true
        target = self

        let icon: String
        let color: NSColor
        switch fileItem {
        case let fileItem as Folder:
            let subMenu = NSMenu()
            submenu = subMenu
            icon = fileItem.systemImage
            color = NSColor(named: "FolderBlue") ?? NSColor(.secondary)

        case let fileItem as File:
            icon = fileItem.systemImage
            color = NSColor(fileItem.iconColor)
            action = nil

        default: return
        }

        let image = NSImage(
            systemSymbolName: icon,
            accessibilityDescription: icon
        )?.withSymbolConfiguration(.init(paletteColors: [color]))
        self.image = image
        representedObject = fileItem
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    func openFile() {
        if let fileItem = fileItem as? File {
            tappedOpenFile(fileItem)
        }
    }
}
