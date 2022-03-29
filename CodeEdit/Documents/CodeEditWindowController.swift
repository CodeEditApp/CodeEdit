//
//  CodeEditWindowController.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 18.03.22.
//

import Cocoa
import SwiftUI
import CodeFile
import Overlays

class CodeEditWindowController: NSWindowController, NSToolbarDelegate {

    var workspace: WorkspaceDocument?
    var quickOpenPanel: OverlayPanel?

    init(window: NSWindow, workspace: WorkspaceDocument) {
        super.init(window: window)
        print("INIT")
        self.workspace = workspace

        let splitVC = NSSplitViewController()

        let sidebar = NSSplitViewItem(
            sidebarWithViewController: NSHostingController(
                rootView: NavigatorSidebar(workspace: workspace, windowController: self)
            )
        )
        sidebar.minimumThickness = 260
        splitVC.addSplitViewItem(sidebar)

        let content = NSSplitViewItem(
            viewController: NSHostingController(
                rootView: WorkspaceView(windowController: self, workspace: workspace)
            )
        )
        splitVC.addSplitViewItem(content)

        let detail = NSSplitViewItem(
            viewController: NSHostingController(
                rootView: InspectorSidebar(workspace: workspace, windowController: self)
            )
        )
        detail.collapseBehavior = .preferResizingSiblingsWithFixedSplitView

        splitVC.splitView.setHoldingPriority(.dragThatCannotResizeWindow, forSubviewAt: 2)
        splitVC.addSplitViewItem(detail)

        self.splitViewController = splitVC

        let toolbar = NSToolbar(identifier: UUID().uuidString)
        toolbar.delegate = self
        toolbar.displayMode = .labelOnly
        window.toolbarStyle = .unifiedCompact
        window.titlebarSeparatorStyle = .none
        window.toolbar = toolbar

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Dangerous convenience alias so you can access the NSSplitViewController and manipulate it later on
    private var splitViewController: NSSplitViewController! {
        get { return contentViewController as? NSSplitViewController }
        set { contentViewController = newValue }
    }

    @objc func toggleFirstPanel() {
        guard let firstSplitView = splitViewController.splitViewItems.first else { return }
        firstSplitView.animator().isCollapsed.toggle()
    }

    @objc func toggleLastPanel() {
        guard let lastSplitView = splitViewController.splitViewItems.last else { return }
        lastSplitView.animator().isCollapsed.toggle()
        if lastSplitView.animator().isCollapsed {
            window?.toolbar?.removeItem(at: 3)
        } else {
            window?.toolbar?.insertItem(withItemIdentifier: .itemListTrackingSeparator, at: 3)
        }
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .toggleFirstSidebarItem,
            .sidebarTrackingSeparator,
            .flexibleSpace,
            .itemListTrackingSeparator,
            .flexibleSpace,
            .toggleLastSidebarItem
        ]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .toggleFirstSidebarItem,
            .sidebarTrackingSeparator,
            .flexibleSpace,
            .itemListTrackingSeparator,
            .toggleLastSidebarItem
        ]
    }

    // swiftlint:disable all
    func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        switch itemIdentifier {
        case .itemListTrackingSeparator:
            if ((splitViewController) != nil) {
                return NSTrackingSeparatorToolbarItem(
                    identifier: .itemListTrackingSeparator,
                    splitView: splitViewController.splitView,
                    dividerIndex: 1
                )
            } else {
                return nil
            }
        case .toggleFirstSidebarItem:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.toggleFirstSidebarItem)
            toolbarItem.label = "Sidebar"
            toolbarItem.paletteLabel = "Sidebar"
            toolbarItem.toolTip = "Toggle Sidebar"
            toolbarItem.isBordered = true
            toolbarItem.target = self
            toolbarItem.action = #selector(self.toggleFirstPanel)
            toolbarItem.image = NSImage(
                systemSymbolName: "sidebar.leading",
                accessibilityDescription: nil
            )?.withSymbolConfiguration(.init(scale: .large))

            let menuItem = NSMenuItem()
            menuItem.submenu = nil
            menuItem.title = "Sidebar"

            toolbarItem.menuFormRepresentation = menuItem
            return toolbarItem
        case .toggleLastSidebarItem:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.toggleFirstSidebarItem)
            toolbarItem.label = "Sidebar"
            toolbarItem.paletteLabel = "Sidebar"
            toolbarItem.toolTip = "Toggle Sidebar"
            toolbarItem.target = self
            toolbarItem.action = #selector(self.toggleLastPanel)
            toolbarItem.image = NSImage(
                systemSymbolName: "sidebar.trailing",
                accessibilityDescription: nil
            )?.withSymbolConfiguration(.init(scale: .small))

            let menuItem = NSMenuItem()
            menuItem.submenu = nil
            menuItem.title = "Sidebar"

            toolbarItem.menuFormRepresentation = menuItem
            return toolbarItem
        default:
            return NSToolbarItem(itemIdentifier: itemIdentifier)
        }
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's
        // window has been loaded from its nib file.
    }

    private func getSelectedCodeFile() -> CodeFileDocument? {
        guard let id = workspace?.selectionState.selectedId else { return nil }
        guard let item = workspace?.selectionState.openFileItems.first(where: { item in
            return item.id == id
        }) else { return nil }
        guard let file = workspace?.selectionState.openedCodeFiles[item] else { return nil }
        return file
    }

    @IBAction func saveDocument(_ sender: Any) {
        getSelectedCodeFile()?.save(sender)
    }

    @IBAction func openQuickly(_ sender: Any) {
        if let workspace = workspace, let state = workspace.quickOpenState {
            if let quickOpenPanel = quickOpenPanel {
                if quickOpenPanel.isKeyWindow {
                    quickOpenPanel.close()
                    return
                } else {
                    window?.addChildWindow(quickOpenPanel, ordered: .above)
                    quickOpenPanel.makeKeyAndOrderFront(self)
                }
            } else {
                let panel = OverlayPanel()
                self.quickOpenPanel = panel
                let contentView = QuickOpenView(state: state) {
                    panel.close()
                }
                panel.contentView = NSHostingView(rootView: contentView)
                window?.addChildWindow(panel, ordered: .above)
                panel.makeKeyAndOrderFront(self)
            }
        }
    }
}

private extension NSToolbarItem.Identifier {
    static let toggleFirstSidebarItem: NSToolbarItem.Identifier = NSToolbarItem.Identifier("ToggleFirstSidebarItem")
    static let toggleLastSidebarItem: NSToolbarItem.Identifier = NSToolbarItem.Identifier("ToggleLastSidebarItem")
    static let itemListTrackingSeparator = NSToolbarItem.Identifier("ItemListTrackingSeparator")
}
