//
//  EditorJumpBarMenu.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/29.
//

import AppKit

final class EditorJumpBarMenu: NSMenu, NSMenuDelegate {
    private let fileItems: [CEWorkspaceFile]
    private weak var fileManager: CEWorkspaceFileManager?
    private let tappedOpenFile: (CEWorkspaceFile) -> Void

    init(
        fileItems: [CEWorkspaceFile],
        fileManager: CEWorkspaceFileManager,
        tappedOpenFile: @escaping (CEWorkspaceFile) -> Void
    ) {
        self.fileItems = fileItems
        self.fileManager = fileManager
        self.tappedOpenFile = tappedOpenFile
        super.init(title: "")
        delegate = self
        fileItems.forEach { item in
            let menuItem = JumpBarMenuItem(fileItem: item, tappedOpenFile: tappedOpenFile)
            menuItem.onStateImage = nil
            self.addItem(menuItem)
        }
        autoenablesItems = false
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Only when menu item is highlighted then generate its submenu
    func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        if let highlightedItem = item, let submenuItems = highlightedItem.submenu?.items, submenuItems.isEmpty {
            if let highlightedFileItem = highlightedItem.representedObject as? CEWorkspaceFile {
                highlightedItem.submenu = generateSubmenu(highlightedFileItem)
            }
        }
    }

    private func generateSubmenu(_ fileItem: CEWorkspaceFile) -> EditorJumpBarMenu? {
        if let fileManager = fileManager,
           let children = fileManager.childrenOfFile(fileItem) {
            let menu = EditorJumpBarMenu(
                fileItems: children,
                fileManager: fileManager,
                tappedOpenFile: tappedOpenFile
            )
            return menu
        }
        return nil
    }
}

final class JumpBarMenuItem: NSMenuItem {
    private let fileItem: CEWorkspaceFile
    private let tappedOpenFile: (CEWorkspaceFile) -> Void
    private let generalSettings = Settings.shared.preferences.general

    init(
        fileItem: CEWorkspaceFile,
        tappedOpenFile: @escaping (CEWorkspaceFile) -> Void
    ) {
        self.fileItem = fileItem
        self.tappedOpenFile = tappedOpenFile
        super.init(title: fileItem.name, action: #selector(openFile), keyEquivalent: "")
        var color = NSColor(fileItem.iconColor)
        isEnabled = true
        target = self
        if fileItem.isFolder {
            let subMenu = NSMenu()
            submenu = subMenu
            color = NSColor(named: "FolderBlue") ?? NSColor(.secondary)
        }
        if generalSettings.fileIconStyle == .monochrome {
            color = NSColor(named: "CoolGray") ?? NSColor(.gray)
        }
        let image = fileItem.nsIcon.withSymbolConfiguration(.init(paletteColors: [color]))
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
