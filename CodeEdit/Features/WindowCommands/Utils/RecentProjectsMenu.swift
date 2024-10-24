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

        for projectPath in RecentProjectsStore.recentProjectURLs().prefix(10) {
            let icon = NSWorkspace.shared.icon(forFile: projectPath.path())
            icon.size = NSSize(width: 16, height: 16)

            let primaryItem = NSMenuItem(
                title: projectPath.lastPathComponent,
                action: #selector(recentProjectItemClicked(_:)),
                keyEquivalent: ""
            )
            primaryItem.target = self
            primaryItem.image = icon
            primaryItem.representedObject = projectPath

//            let alternateTitle = NSMutableAttributedString(
//                string: projectPath.lastPathComponent + " ", attributes: [.foregroundColor: NSColor.labelColor]
//            )
//            alternateTitle.append(NSAttributedString(
//                string: path,
//                attributes: [.foregroundColor: NSColor.secondaryLabelColor]
//            ))
//
//            let alternateItem = NSMenuItem(
//                title: "",
//                action: #selector(recentProjectItemClicked(_:)),
//                keyEquivalent: ""
//            )
//            alternateItem.attributedTitle = alternateTitle
//            alternateItem.target = self
//            alternateItem.image = icon
//            alternateItem.representedObject = projectPath
//            alternateItem.isAlternate = true
//            alternateItem.keyEquivalentModifierMask = [.option]

            menu.addItem(primaryItem)
//            menu.addItem(alternateItem)
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

    private func duplicateProjectMenuItem(_ projectPath: URL) -> NSMenuItem {
        let item = NSMenuItem()
        let stack = NSStackView()
        stack.orientation = .horizontal
        stack.spacing = 8

        let icon = NSImageView(image: NSWorkspace.shared.icon(forFile: projectPath.path()))
        icon.frame.size = NSSize(width: 16, height: 16)
        let title = NSTextField(labelWithString: projectPath.lastPathComponent)

        let separator = NSTextField(labelWithString: "⎯")

        let projectParent = projectPath.deletingLastPathComponent()

        let secondaryIcon = NSImageView(image: NSWorkspace.shared.icon(forFile: projectParent.path()))
        secondaryIcon.frame.size = NSSize(width: 16, height: 16)
        let secondaryTitle = NSTextField(
            labelWithString: projectParent.path(percentEncoded: false).abbreviatingWithTildeInPath()
        )

        stack.addArrangedSubview(icon)
        stack.addArrangedSubview(title)
        stack.addArrangedSubview(secondaryIcon)
        stack.addArrangedSubview(secondaryTitle)

        item.view = stack

        return item
    }
}

//struct RecentProjectsMenu: View {
//    @State private var recentProjects: [URL] = []
//    @State private var controlKeyPressed: Bool = false
//
//    var body: some View {
//        Group {
//            ForEach(recentProjects, id: \.self) { url in
//                Button {
//                    NSDocumentController.shared.openDocument(
//                        withContentsOf: url,
//                        display: true,
//                        completionHandler: { _, _, _ in }
//                    )
//                } label: {
//                    RecentProjectMenuItem(
//                        projectPath: url,
//                        controlKeyPressed: controlKeyPressed
////                        hasDuplicate: recentProjects.contains(where: {
////                            $0 != url && $0.lastPathComponent == url.lastPathComponent
////                        })
//                    )
//                }
//            }
//            Divider()
//            Button {
//                RecentProjectsStore.clearList()
//            } label: {
//                Text("Clear Recent Menu")
//            }
//        }
//        .onAppear {
//            updateProjects()
//        }
//        .onReceive(NotificationCenter.default.publisher(for: RecentProjectsStore.didUpdateNotification)) { _ in
//            updateProjects()
//        }
//        .onReceive(NSEvent.publisher(scope: .local, matching: .flagsChanged)) { output in
//            controlKeyPressed = output.modifierFlags.contains(.control)
//        }
//    }
//
//    private func updateProjects() {
//        recentProjects = Array(RecentProjectsStore.recentProjectURLs().prefix(10))
//    }
//}
