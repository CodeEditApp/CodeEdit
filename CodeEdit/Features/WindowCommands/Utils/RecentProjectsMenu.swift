//
//  RecentProjectsMenu.swift
//  CodeEdit
//
//  Created by Khan Winter on 10/22/24.
//

import AppKit

class RecentProjectsMenu: NSObject {
    func makeMenu() -> NSMenu {
        let menu = NSMenu(title: NSLocalizedString("Open Recent", comment: "Open Recent menu title"))

        let paths = RecentProjectsStore.recentProjectURLs().prefix(10)

        for projectPath in paths {
            let icon = NSWorkspace.shared.icon(forFile: projectPath.path())
            icon.size = NSSize(width: 16, height: 16)
            let alternateTitle = alternateTitle(for: projectPath)

            let primaryItem = NSMenuItem(
                title: projectPath.lastPathComponent,
                action: #selector(recentProjectItemClicked(_:)),
                keyEquivalent: ""
            )
            primaryItem.target = self
            primaryItem.image = icon
            primaryItem.representedObject = projectPath

            let containsDuplicate = paths.contains { url in
                url != projectPath && url.lastPathComponent == projectPath.lastPathComponent
            }

            // If there's a duplicate, add the path.
            if containsDuplicate {
                primaryItem.attributedTitle = alternateTitle
            }

            let alternateItem = NSMenuItem(
                title: "",
                action: #selector(recentProjectItemClicked(_:)),
                keyEquivalent: ""
            )
            alternateItem.attributedTitle = alternateTitle
            alternateItem.target = self
            alternateItem.image = icon
            alternateItem.representedObject = projectPath
            alternateItem.isAlternate = true
            alternateItem.keyEquivalentModifierMask = [.option]

            menu.addItem(primaryItem)
            menu.addItem(alternateItem)
        }

        menu.addItem(NSMenuItem.separator())

        let clearMenuItem = NSMenuItem(
            title: NSLocalizedString("Clear Menu", comment: "Recent project menu clear button"),
            action: #selector(clearMenuItemClicked(_:)),
            keyEquivalent: ""
        )
        clearMenuItem.target = self
        menu.addItem(clearMenuItem)

        return menu
    }

    private func alternateTitle(for projectPath: URL) -> NSAttributedString {
        let parentPath = projectPath
            .deletingLastPathComponent()
            .path(percentEncoded: false)
            .abbreviatingWithTildeInPath()
        let alternateTitle = NSMutableAttributedString(
            string: projectPath.lastPathComponent + " ", attributes: [.foregroundColor: NSColor.labelColor]
        )
        alternateTitle.append(NSAttributedString(
            string: parentPath,
            attributes: [.foregroundColor: NSColor.secondaryLabelColor]
        ))
        return alternateTitle
    }

    @objc
    func recentProjectItemClicked(_ sender: NSMenuItem) {
        guard let projectURL = sender.representedObject as? URL else {
            return
        }
        CodeEditDocumentController.shared.openDocument(
            withContentsOf: projectURL,
            display: true,
            completionHandler: { _, _, _ in }
        )
    }

    @objc
    func clearMenuItemClicked(_ sender: NSMenuItem) {
        RecentProjectsStore.clearList()
    }
}
