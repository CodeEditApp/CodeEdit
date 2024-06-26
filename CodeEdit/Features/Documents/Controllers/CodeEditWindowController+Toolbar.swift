//
//  CodeEditWindowController+Toolbar.swift
//  CodeEdit
//
//  Created by Daniel Zhu on 5/10/24.
//

import AppKit
import SwiftUI

extension CodeEditWindowController {
    internal func setupToolbar() {
        let toolbar = NSToolbar(identifier: UUID().uuidString)
        toolbar.delegate = self
        toolbar.displayMode = .labelOnly
        toolbar.showsBaselineSeparator = false
        self.window?.titleVisibility = toolbarCollapsed ? .visible : .hidden
        self.window?.toolbarStyle = .unifiedCompact
        self.window?.titlebarSeparatorStyle = .automatic
        self.window?.toolbar = toolbar
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .toggleFirstSidebarItem,
            .flexibleSpace,
            .stopTaskSidebarItem,
            .startTaskSidebarItem,
            .sidebarTrackingSeparator,
            .branchPicker,
            .flexibleSpace,
            .activityViewer,
            .flexibleSpace,
            .itemListTrackingSeparator,
            .flexibleSpace,
            .toggleLastSidebarItem
        ]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .toggleFirstSidebarItem,
            .sidebarTrackingSeparator,
            .flexibleSpace,
            .itemListTrackingSeparator,
            .toggleLastSidebarItem,
            .branchPicker,
            .activityViewer,
            .startTaskSidebarItem,
            .stopTaskSidebarItem
        ]
    }

    func toggleToolbar() {
        toolbarCollapsed.toggle()
        updateToolbarVisibility()
    }

    private func updateToolbarVisibility() {
        if toolbarCollapsed {
            window?.titleVisibility = .visible
            window?.title = workspace?.workspaceFileManager?.folderUrl.lastPathComponent ?? "Empty"
            window?.toolbar = nil
        } else {
            window?.titleVisibility = .hidden
            setupToolbar()
        }
    }

    // swiftlint:disable:next function_body_length
    func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        switch itemIdentifier {
        case .itemListTrackingSeparator:
            guard let splitViewController else { return nil }

            return NSTrackingSeparatorToolbarItem(
                identifier: .itemListTrackingSeparator,
                splitView: splitViewController.splitView,
                dividerIndex: 1
            )
        case .toggleFirstSidebarItem:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.toggleFirstSidebarItem)
            toolbarItem.label = "Navigator Sidebar"
            toolbarItem.paletteLabel = " Navigator Sidebar"
            toolbarItem.toolTip = "Hide or show the Navigator"
            toolbarItem.isBordered = true
            toolbarItem.target = self
            toolbarItem.action = #selector(self.toggleFirstPanel)
            toolbarItem.image = NSImage(
                systemSymbolName: "sidebar.leading",
                accessibilityDescription: nil
            )?.withSymbolConfiguration(.init(scale: .large))

            return toolbarItem
        case .toggleLastSidebarItem:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.toggleLastSidebarItem)
            toolbarItem.label = "Inspector Sidebar"
            toolbarItem.paletteLabel = "Inspector Sidebar"
            toolbarItem.toolTip = "Hide or show the Inspectors"
            toolbarItem.isBordered = true
            toolbarItem.target = self
            toolbarItem.action = #selector(self.toggleLastPanel)
            toolbarItem.image = NSImage(
                systemSymbolName: "sidebar.trailing",
                accessibilityDescription: nil
            )?.withSymbolConfiguration(.init(scale: .large))

            return toolbarItem
        case .stopTaskSidebarItem:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.stopTaskSidebarItem)
            toolbarItem.label = "Stop"
            toolbarItem.paletteLabel = "Stop"
            toolbarItem.toolTip = "Stop selected task"
            toolbarItem.isBordered = true
            toolbarItem.target = self
            toolbarItem.action = #selector(self.terminateActiveTask)
            toolbarItem.image = NSImage(
                systemSymbolName: "stop.fill",
                accessibilityDescription: nil
            )?.withSymbolConfiguration(.init(scale: .large))

            return toolbarItem
        case .startTaskSidebarItem:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.startTaskSidebarItem)
            toolbarItem.label = "Start"
            toolbarItem.paletteLabel = "Start"
            toolbarItem.toolTip = "Start selected task"
            toolbarItem.isBordered = true
            toolbarItem.target = self
            toolbarItem.action = #selector(self.runActiveTask)
            toolbarItem.image = NSImage(
                systemSymbolName: "play.fill",
                accessibilityDescription: nil
            )?.withSymbolConfiguration(.init(scale: .large))

            return toolbarItem
        case .branchPicker:
            let toolbarItem = NSToolbarItem(itemIdentifier: .branchPicker)
            let view = NSHostingView(
                rootView: ToolbarBranchPicker(
                    workspaceFileManager: workspace?.workspaceFileManager
                )
            )
            toolbarItem.view = view

            return toolbarItem
        case .activityViewer:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.activityViewer)
            toolbarItem.visibilityPriority = .user
            let view = NSHostingView(
                rootView: ActivityViewer(
                    workspaceFileManager: workspace?.workspaceFileManager,
                    workspaceSettings: workspaceSettings!, // TODO: Don't force unwrap
                    taskNotificationHandler: taskNotificationHandler,
                    taskManager: taskManager!
                )
            )

            let weakWidth = view.widthAnchor.constraint(equalToConstant: 650)
            weakWidth.priority = .defaultLow
            let strongWidth = view.widthAnchor.constraint(greaterThanOrEqualToConstant: 200)
            strongWidth.priority = .defaultHigh

            NSLayoutConstraint.activate([
                weakWidth,
                strongWidth
            ])

            toolbarItem.view = view
            return toolbarItem
        default:
            return NSToolbarItem(itemIdentifier: itemIdentifier)
        }
    }

    @objc
    private func runActiveTask() {
        guard let taskManager else { return }
        taskManager.executeActiveTask()
    }

    @objc
    private func terminateActiveTask() {
        guard let taskManager else { return }
        taskManager.terminateActiveTask()
    }
}
