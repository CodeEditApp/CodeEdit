//
//  CodeEditWindowController.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 18.03.22.
//

import Cocoa
import SwiftUI

final class CodeEditWindowController: NSWindowController, NSToolbarDelegate {
    static let minSidebarWidth: CGFloat = 242

    private var prefs: AppPreferencesModel = .shared

    var workspace: WorkspaceDocument?
    var quickOpenPanel: OverlayPanel?
    var commandPalettePanel: OverlayPanel?

    private var splitViewController: NSSplitViewController! {
        get { contentViewController as? NSSplitViewController }
        set { contentViewController = newValue }
    }

    init(window: NSWindow, workspace: WorkspaceDocument) {
        super.init(window: window)
        self.workspace = workspace

        setupSplitView(with: workspace)
        setupToolbar()
        registerCommands()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// These are example items that added as commands to command palette
    func registerCommands() {
        CommandManager.shared.addCommand(
            name: "Quick Open",
            title: "Quick Open",
            id: "quick_open",
            command: CommandClosureWrapper(closure: {
                self.openQuickly(self)
            })
        )

        CommandManager.shared.addCommand(
            name: "Toggle Left Sidebar",
            title: "Toggle Left Sidebar",
            id: "toggle_left_sidebar",
            command: CommandClosureWrapper(closure: {
                self.toggleFirstPanel()
            })
        )

        CommandManager.shared.addCommand(
            name: "Toggle Right Sidebar",
            title: "Toggle Right Sidebar",
            id: "toggle_right_sidebar",
            command: CommandClosureWrapper(closure: {
                self.toggleLastPanel()
            })
        )
    }

    private func setupSplitView(with workspace: WorkspaceDocument) {
        let feedbackPerformer = NSHapticFeedbackManager.defaultPerformer
        let splitVC = CodeEditSplitViewController(feedbackPerformer: feedbackPerformer)

        let navigatorView = NavigatorSidebarView(workspace: workspace)
        let navigator = NSSplitViewItem(
            sidebarWithViewController: NSHostingController(rootView: navigatorView)
        )
        navigator.titlebarSeparatorStyle = .none
        navigator.minimumThickness = Self.minSidebarWidth
        navigator.collapseBehavior = .useConstraints
        splitVC.addSplitViewItem(navigator)

        let workspaceView = WindowObserver(window: window!) {
            WorkspaceView(workspace: workspace)
        }

        let mainContent = NSSplitViewItem(
            viewController: NSHostingController(rootView: workspaceView)
        )
        mainContent.titlebarSeparatorStyle = .line
        splitVC.addSplitViewItem(mainContent)

        let inspectorView = InspectorSidebarView(workspace: workspace)
        let inspector = NSSplitViewItem(
            viewController: NSHostingController(rootView: inspectorView)
        )
        inspector.titlebarSeparatorStyle = .none
        inspector.minimumThickness = Self.minSidebarWidth
        inspector.isCollapsed = true
        inspector.canCollapse = true
        inspector.collapseBehavior = .useConstraints
        splitVC.addSplitViewItem(inspector)

        self.splitViewController = splitVC
    }

    private func setupToolbar() {
        let toolbar = NSToolbar(identifier: UUID().uuidString)
        toolbar.delegate = self
        toolbar.displayMode = .labelOnly
        toolbar.showsBaselineSeparator = false
        self.window?.titleVisibility = .hidden
        self.window?.toolbarStyle = .unifiedCompact
        if prefs.preferences.general.tabBarStyle == .native {
            // Set titlebar background as transparent by default in order to
            // style the toolbar background in native tab bar style.
            self.window?.titlebarAppearsTransparent = true
            self.window?.titlebarSeparatorStyle = .none
        } else {
            // In xcode tab bar style, we use default toolbar background with
            // line separator.
            self.window?.titlebarAppearsTransparent = false
            self.window?.titlebarSeparatorStyle = .automatic
        }
        self.window?.toolbar = toolbar
    }

    // MARK: - Toolbar

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .toggleFirstSidebarItem,
            .sidebarTrackingSeparator,
            .branchPicker,
            .flexibleSpace,
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
            .branchPicker
        ]
    }

    func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        switch itemIdentifier {
        case .itemListTrackingSeparator:
                guard let splitViewController = splitViewController else {
                    return nil
                }

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
        case .branchPicker:
            let toolbarItem = NSToolbarItem(itemIdentifier: .branchPicker)
            let view = NSHostingView(
                rootView: ToolbarBranchPicker(
                    shellClient: currentWorld.shellClient,
                    workspace: workspace?.workspaceClient
                )
            )
            toolbarItem.view = view

            return toolbarItem
        default:
            return NSToolbarItem(itemIdentifier: itemIdentifier)
        }
    }

    override func windowDidLoad() {
        super.windowDidLoad()
    }

    @objc func toggleFirstPanel() {
        guard let firstSplitView = splitViewController.splitViewItems.first else { return }
        firstSplitView.animator().isCollapsed.toggle()
    }

    @objc func toggleLastPanel() {
        guard let lastSplitView = splitViewController.splitViewItems.last else { return }
        lastSplitView.animator().isCollapsed.toggle()
        if lastSplitView.isCollapsed {
            window?.toolbar?.removeItem(at: 4)
        } else {
            window?.toolbar?.insertItem(withItemIdentifier: .itemListTrackingSeparator, at: 4)
        }
    }

    private func getSelectedCodeFile() -> CodeFileDocument? {
        guard let id = workspace?.selectionState.selectedId else { return nil }
        guard let item = workspace?.selectionState.openFileItems.first(where: { item in
            item.tabID == id
        }) else { return nil }
        guard let file = workspace?.selectionState.openedCodeFiles[item] else { return nil }
        return file
    }

    @IBAction func saveDocument(_ sender: Any) {
        getSelectedCodeFile()?.save(sender)
        workspace?.convertTemporaryTab()
    }

    @IBAction func openCommandPalette(_ sender: Any) {
        if let workspace = workspace, let state = workspace.commandsPaletteState {
            if let commandPalettePanel = commandPalettePanel {
                if commandPalettePanel.isKeyWindow {
                    commandPalettePanel.close()
                    state.reset()
                    return
                } else {
                    state.reset()
                    window?.addChildWindow(commandPalettePanel, ordered: .above)
                    commandPalettePanel.makeKeyAndOrderFront(self)
                }
            } else {
                let panel = OverlayPanel()
                self.commandPalettePanel = panel
                let contentView = CommandPaletteView(state: state, closePalette: panel.close)
                panel.contentView = NSHostingView(rootView: contentView)
                window?.addChildWindow(panel, ordered: .above)
                panel.makeKeyAndOrderFront(self)
            }
        }
    }

    @IBAction func openQuickly(_ sender: Any) {
        if let workspace = workspace, let state = workspace.quickOpenViewModel {
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
                let contentView = QuickOpenView(
                    state: state,
                    onClose: { panel.close() },
                    openFile: workspace.openTab(item:)
                )
                panel.contentView = NSHostingView(rootView: contentView)
                window?.addChildWindow(panel, ordered: .above)
                panel.makeKeyAndOrderFront(self)
            }
        }
    }
}

extension NSToolbarItem.Identifier {
    static let toggleFirstSidebarItem: NSToolbarItem.Identifier = NSToolbarItem.Identifier("ToggleFirstSidebarItem")
    static let toggleLastSidebarItem: NSToolbarItem.Identifier = NSToolbarItem.Identifier("ToggleLastSidebarItem")
    static let itemListTrackingSeparator = NSToolbarItem.Identifier("ItemListTrackingSeparator")
    static let branchPicker: NSToolbarItem.Identifier = NSToolbarItem.Identifier("BranchPicker")
}
