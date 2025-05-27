//
//  RecentProjectsMenu.swift
//  CodeEdit
//
//  Created by Khan Winter on 10/22/24.
//

import AppKit

class RecentProjectsMenu: NSObject {
    let projectsStore: RecentProjectsStore

    init(projectsStore: RecentProjectsStore = .default) {
        self.projectsStore = projectsStore
    }

    func makeMenu() -> NSMenu {
        let menu = NSMenu(title: NSLocalizedString("Open Recent", comment: "Open Recent menu title"))

        addFileURLs(to: menu, fileURLs: projectsStore.recentProjectURLs().prefix(10))
        menu.addItem(NSMenuItem.separator())
        addFileURLs(to: menu, fileURLs: projectsStore.recentFileURLs().prefix(10))
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

    private func addFileURLs(to menu: NSMenu, fileURLs: ArraySlice<URL>) {
        for url in fileURLs {
            let icon = NSWorkspace.shared.icon(forFile: url.path())
            icon.size = NSSize(width: 16, height: 16)
            let alternateTitle = alternateTitle(for: url)

            let primaryItem = NSMenuItem(
                title: url.lastPathComponent,
                action: #selector(recentProjectItemClicked(_:)),
                keyEquivalent: ""
            )
            primaryItem.target = self
            primaryItem.image = icon
            primaryItem.representedObject = url

            let containsDuplicate = fileURLs.contains { otherURL in
                url != otherURL && url.lastPathComponent == otherURL.lastPathComponent
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
            alternateItem.representedObject = url
            alternateItem.isAlternate = true
            alternateItem.keyEquivalentModifierMask = [.option]

            menu.addItem(primaryItem)
            menu.addItem(alternateItem)
        }
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
        projectsStore.clearList()
    }
}
