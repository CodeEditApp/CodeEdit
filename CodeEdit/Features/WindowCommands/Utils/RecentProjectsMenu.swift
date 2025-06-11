//
//  RecentProjectsMenu.swift
//  CodeEdit
//
//  Created by Khan Winter on 10/22/24.
//

import AppKit
import WelcomeWindow

@MainActor
final class RecentProjectsMenu: NSObject, NSMenuDelegate {

    // MARK: - Menu construction

    private let menuTitle = NSLocalizedString(
        "Open Recent",
        comment: "Open Recent menu title"
    )

    private lazy var menu: NSMenu = {
        let menu = NSMenu(title: menuTitle)
        menu.delegate = self           // <- make the menu ask us for updates
        return menu
    }()

    /// Entry point used by the caller (e.g. the main menu bar template).
    func makeMenu() -> NSMenu {
        rebuildMenu()
        return menu
    }

    /// Called automatically right before the menu gets displayed.
    func menuNeedsUpdate(_ menu: NSMenu) {
        rebuildMenu()
    }

    // Rebuilds the whole “Open Recent” menu.
    private func rebuildMenu() {
        menu.removeAllItems()

        addFileURLs(
            to: menu,
            fileURLs: RecentsStore.recentDirectoryURLs().prefix(10)
        )
        menu.addItem(.separator())
        addFileURLs(
            to: menu,
            fileURLs: RecentsStore.recentFileURLs().prefix(10)
        )
        menu.addItem(.separator())

        let clearMenuItem = NSMenuItem(
            title: NSLocalizedString(
                "Clear Menu",
                comment: "Recent project menu clear button"
            ),
            action: #selector(clearMenuItemClicked(_:)),
            keyEquivalent: ""
        )
        clearMenuItem.target = self
        menu.addItem(clearMenuItem)
    }

    // MARK: - Item creation helpers

    private func addFileURLs(to menu: NSMenu, fileURLs: ArraySlice<URL>) {
        for url in fileURLs {
            let icon = NSWorkspace.shared.icon(forFile: url.path(percentEncoded: false))
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
            string: projectPath.lastPathComponent + " ",
            attributes: [.foregroundColor: NSColor.labelColor]
        )
        alternateTitle.append(NSAttributedString(
            string: parentPath,
            attributes: [.foregroundColor: NSColor.secondaryLabelColor]
        ))
        return alternateTitle
    }

    // MARK: - Actions

    @objc
    private func recentProjectItemClicked(_ sender: NSMenuItem) {
        guard let projectURL = sender.representedObject as? URL else { return }
        CodeEditDocumentController.shared.openDocument(
            withContentsOf: projectURL,
            display: true,
            completionHandler: { _, _, _ in }
        )
    }

    @objc
    private func clearMenuItemClicked(_ sender: NSMenuItem) {
        RecentsStore.clearList()
        rebuildMenu()
    }
}

// MARK: - Helpers

private extension String {
    func abbreviatingWithTildeInPath() -> String {
        (self as NSString).abbreviatingWithTildeInPath
    }
}
