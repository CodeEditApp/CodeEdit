//
//  CodeEditWindowController+Toolbar.swift
//  CodeEdit
//
//  Created by Daniel Zhu on 5/10/24.
//

import AppKit
import SwiftUI
import Combine

extension CodeEditWindowController {
    internal func setupToolbar() {
        let toolbar = NSToolbar(identifier: UUID().uuidString)
        toolbar.delegate = self
        toolbar.showsBaselineSeparator = false
        self.window?.titleVisibility = toolbarCollapsed ? .visible : .hidden
        if #available(macOS 26, *) {
            self.window?.toolbarStyle = .automatic
            toolbar.centeredItemIdentifiers = [.activityViewer, .notificationItem]
            toolbar.displayMode = .iconOnly
            self.window?.titlebarAppearsTransparent = true
        } else {
            self.window?.toolbarStyle = .unifiedCompact
            toolbar.displayMode = .labelOnly
        }
        self.window?.titlebarSeparatorStyle = .automatic
        self.window?.toolbar = toolbar
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        var items: [NSToolbarItem.Identifier] = [
            .toggleFirstSidebarItem,
            .flexibleSpace,
        ]

        if #available(macOS 26, *) {
            items += [.taskSidebarItem]
        } else {
            items += [
                .stopTaskSidebarItem,
                .startTaskSidebarItem,
            ]
        }

        items += [
            .sidebarTrackingSeparator,
            .branchPicker,
            .flexibleSpace,
        ]

        if #available(macOS 26, *) {
            items += [
                .activityViewer,
                .space,
                .notificationItem,
            ]
        } else {
            items += [
                .activityViewer,
                .notificationItem,
                .flexibleSpace,
            ]
        }

        items += [
            .flexibleSpace,
            .itemListTrackingSeparator,
            .flexibleSpace,
            .toggleLastSidebarItem
        ]

        return items
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        var items: [NSToolbarItem.Identifier] = [
            .toggleFirstSidebarItem,
            .sidebarTrackingSeparator,
            .flexibleSpace,
            .itemListTrackingSeparator,
            .toggleLastSidebarItem,
            .branchPicker,
            .activityViewer,
            .notificationItem,
        ]

        if #available(macOS 26, *) {
            items += [
                .taskSidebarItem
            ]
        } else {
            items += [
                .startTaskSidebarItem,
                .stopTaskSidebarItem
            ]
        }

        return items
    }

    func toggleToolbar() {
        toolbarCollapsed.toggle()
        workspace?.addToWorkspaceState(key: .toolbarCollapsed, value: toolbarCollapsed)
        updateToolbarVisibility()
    }

    func updateToolbarVisibility() {
        if toolbarCollapsed {
            window?.titleVisibility = .visible
            window?.title = workspace?.workspaceFileManager?.folderUrl.lastPathComponent ?? "Empty"
            window?.toolbar = nil
        } else {
            window?.titleVisibility = .hidden
            setupToolbar()
        }
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
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
            toolbarItem.paletteLabel = " Navigator Sidebar"
            toolbarItem.toolTip = "Hide or show the Navigator"
            toolbarItem.isBordered = true
            toolbarItem.target = self
            toolbarItem.action = #selector(self.objcToggleFirstPanel)
            toolbarItem.image = NSImage(
                systemSymbolName: "sidebar.leading",
                accessibilityDescription: nil
            )?.withSymbolConfiguration(.init(scale: .large))

            return toolbarItem
        case .toggleLastSidebarItem:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.toggleLastSidebarItem)
            toolbarItem.paletteLabel = "Inspector Sidebar"
            toolbarItem.toolTip = "Hide or show the Inspectors"
            toolbarItem.isBordered = true
            toolbarItem.target = self
            toolbarItem.action = #selector(self.objcToggleLastPanel)
            toolbarItem.image = NSImage(
                systemSymbolName: "sidebar.trailing",
                accessibilityDescription: nil
            )?.withSymbolConfiguration(.init(scale: .large))

            return toolbarItem
        case .stopTaskSidebarItem:
            return stopTaskSidebarItem()
        case .startTaskSidebarItem:
            return startTaskSidebarItem()
        case .branchPicker:
            let toolbarItem = NSToolbarItem(itemIdentifier: .branchPicker)
            let view = NSHostingView(
                rootView: ToolbarBranchPicker(
                    workspaceFileManager: workspace?.workspaceFileManager
                )
            )
            toolbarItem.view = view
            toolbarItem.isBordered = false
            return toolbarItem
        case .activityViewer:
            return activityViewerItem()
        case .notificationItem:
            return notificationItem()
        case .taskSidebarItem:
            guard #available(macOS 26, *) else {
                fatalError("Unified task sidebar item used on pre-tahoe platform.")
            }
            guard let workspace,
                    let stop = StopTaskToolbarItem(workspace: workspace) else {
                return nil
            }
            let start = StartTaskToolbarItem(workspace: workspace)

            let group = NSToolbarItemGroup(itemIdentifier: .taskSidebarItem)
            group.isBordered = true
            group.controlRepresentation = .expanded
            group.selectionMode = .momentary
            group.subitems = [stop, start]

            return group
        default:
            return NSToolbarItem(itemIdentifier: itemIdentifier)
        }
    }

    private func stopTaskSidebarItem() -> NSToolbarItem? {
        let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.stopTaskSidebarItem)

        guard let taskManager = workspace?.taskManager else { return nil }

        let view = NSHostingView(
            rootView: StopTaskToolbarButton(taskManager: taskManager)
        )
        toolbarItem.view = view

        return toolbarItem
    }

    private func startTaskSidebarItem() -> NSToolbarItem? {
        let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.startTaskSidebarItem)

        guard let taskManager = workspace?.taskManager else { return nil }
        guard let workspace = workspace else { return nil }

        let view = NSHostingView(
            rootView: StartTaskToolbarButton(taskManager: taskManager)
                .environmentObject(workspace)
        )
        toolbarItem.view = view

        return toolbarItem
    }

    private func notificationItem() -> NSToolbarItem? {
        let toolbarItem = NSToolbarItem(itemIdentifier: .notificationItem)
        guard let workspace = workspace else { return nil }
        let view = NSHostingView(rootView: NotificationToolbarItem().environmentObject(workspace))
        toolbarItem.view = view
        return toolbarItem
    }

    private func activityViewerItem() -> NSToolbarItem? {
        let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.activityViewer)
        toolbarItem.visibilityPriority = .user
        guard let workspaceSettingsManager = workspace?.workspaceSettingsManager,
              let taskNotificationHandler = workspace?.taskNotificationHandler,
              let taskManager = workspace?.taskManager
        else { return nil }

        let view = NSHostingView(
            rootView: ActivityViewer(
                workspaceFileManager: workspace?.workspaceFileManager,
                workspaceSettingsManager: workspaceSettingsManager,
                taskNotificationHandler: taskNotificationHandler,
                taskManager: taskManager
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
    }
}
