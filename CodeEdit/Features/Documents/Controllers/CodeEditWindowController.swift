//
//  CodeEditWindowController.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 18.03.22.
//

import Cocoa
import SwiftUI

final class CodeEditWindowController: NSWindowController, NSToolbarDelegate, ObservableObject {
    static let minSidebarWidth: CGFloat = 242

    @Published var navigatorCollapsed = false
    @Published var inspectorCollapsed = false

    var observers: [NSKeyValueObservation] = []

    var workspace: WorkspaceDocument?
    var quickOpenPanel: OverlayPanel?
    var commandPalettePanel: OverlayPanel?

    var splitViewController: NSSplitViewController!

    init(window: NSWindow, workspace: WorkspaceDocument) {
        super.init(window: window)
        self.workspace = workspace
        setupSplitView(with: workspace)

        let view = CodeEditSplitView(controller: splitViewController).ignoresSafeArea()

        // An NSHostingController is used, so the root viewController of the window is a SwiftUI-managed one.
        // This allows us to use some SwiftUI features, like focusedSceneObject.
        contentViewController = NSHostingController(rootView: view)

        observers = [
            splitViewController.splitViewItems.first!.observe(\.isCollapsed, changeHandler: { [weak self] item, _ in
                self?.navigatorCollapsed = item.isCollapsed
            }),
            splitViewController.splitViewItems.last!.observe(\.isCollapsed, changeHandler: { [weak self] item, _ in
                self?.navigatorCollapsed = item.isCollapsed
            })
        ]

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
        let splitVC = CodeEditSplitViewController(workspace: workspace, feedbackPerformer: feedbackPerformer)

        let navigatorView = SettingsInjector {
            NavigatorSidebarView(workspace: workspace)
                .environmentObject(workspace)
                .environmentObject(workspace.tabManager)
        }

        let navigator = NSSplitViewItem(
            sidebarWithViewController: NSHostingController(rootView: navigatorView)
        )
        navigator.titlebarSeparatorStyle = .none
        navigator.minimumThickness = Self.minSidebarWidth
        navigator.collapseBehavior = .useConstraints

        splitVC.addSplitViewItem(navigator)

        let workspaceView = SettingsInjector {
            WindowObserver(window: window!) {
                WorkspaceView()
                    .environmentObject(workspace)
                    .environmentObject(workspace.tabManager)
                    .environmentObject(workspace.debugAreaModel)
            }
        }

        let mainContent = NSSplitViewItem(
            viewController: NSHostingController(rootView: workspaceView)
        )
        mainContent.titlebarSeparatorStyle = .line
        mainContent.holdingPriority = .init(50)

        splitVC.addSplitViewItem(mainContent)

        let inspectorView = SettingsInjector {
            InspectorSidebarView()
                .environmentObject(workspace)
                .environmentObject(workspace.tabManager)
        }

        let inspector = NSSplitViewItem(
            viewController: NSHostingController(rootView: inspectorView)
        )
        inspector.titlebarSeparatorStyle = .none
        inspector.minimumThickness = Self.minSidebarWidth
        inspector.isCollapsed = true
        inspector.canCollapse = true
        inspector.collapseBehavior = .useConstraints
        inspector.isSpringLoaded = true

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
        if Settings[\.general].tabBarStyle == .native {
            // Set titlebar background as transparent by default in order to
            // style the toolbar background in native tab bar style.
            self.window?.titlebarSeparatorStyle = .none
        } else {
            // In xcode tab bar style, we use default toolbar background with
            // line separator.
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
            guard let splitViewController else {
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
                    workspaceFileManager: workspace?.workspaceFileManager
                )
            )
            toolbarItem.view = view

            return toolbarItem
        default:
            return NSToolbarItem(itemIdentifier: itemIdentifier)
        }
    }

    private func getSelectedCodeFile() -> CodeFileDocument? {
        workspace?.tabManager.activeTabGroup.selected?.fileDocument
    }

    @IBAction func saveDocument(_ sender: Any) {
        getSelectedCodeFile()?.save(sender)
        workspace?.tabManager.activeTabGroup.temporaryTab = nil
    }

    @IBAction func openCommandPalette(_ sender: Any) {
        if let workspace, let state = workspace.commandsPaletteState {
            if let commandPalettePanel {
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
                panel.contentView = NSHostingView(rootView: SettingsInjector { contentView })
                window?.addChildWindow(panel, ordered: .above)
                panel.makeKeyAndOrderFront(self)
            }
        }
    }

    @IBAction func openQuickly(_ sender: Any) {
        if let workspace, let state = workspace.quickOpenViewModel {
            if let quickOpenPanel {
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
                } openFile: { file in
                    workspace.tabManager.openTab(item: file)
                }

                panel.contentView = NSHostingView(rootView: SettingsInjector { contentView })
                window?.addChildWindow(panel, ordered: .above)
                panel.makeKeyAndOrderFront(self)
            }
        }
    }

    @IBAction func closeCurrentTab(_ sender: Any) {
        if (workspace?.tabManager.activeTabGroup.tabs ?? []).isEmpty {
            self.closeActiveTabGroup(self)
        } else {
            workspace?.tabManager.activeTabGroup.closeCurrentTab()
        }
    }

    @IBAction func closeActiveTabGroup(_ sender: Any) {
        if workspace?.tabManager.tabGroups.findSomeTabGroup(except: workspace?.tabManager.activeTabGroup) == nil {
            NSApp.sendAction(#selector(NSWindow.close), to: nil, from: nil)
        } else {
            workspace?.tabManager.activeTabGroup.close()
        }
    }
}

extension CodeEditWindowController {
    @objc
    func toggleFirstPanel() {
        guard let firstSplitView = splitViewController.splitViewItems.first else { return }
        firstSplitView.animator().isCollapsed.toggle()
        if let codeEditSplitVC = splitViewController as? CodeEditSplitViewController {
            codeEditSplitVC.saveNavigatorCollapsedState(isCollapsed: firstSplitView.isCollapsed)
        }
    }

    @objc
    func toggleLastPanel() {
        guard let lastSplitView = splitViewController.splitViewItems.last else { return }

        if let toolbar = window?.toolbar,
            lastSplitView.isCollapsed,
            !toolbar.items.map(\.itemIdentifier).contains(.itemListTrackingSeparator) {
            window?.toolbar?.insertItem(withItemIdentifier: .itemListTrackingSeparator, at: 4)
        }
        NSAnimationContext.runAnimationGroup { _ in
            lastSplitView.animator().isCollapsed.toggle()
        } completionHandler: { [weak self] in
            if lastSplitView.isCollapsed {
                self?.window?.animator().toolbar?.removeItem(at: 4)
            }
        }

        if let codeEditSplitVC = splitViewController as? CodeEditSplitViewController {
            codeEditSplitVC.saveInspectorCollapsedState(isCollapsed: lastSplitView.isCollapsed)
            codeEditSplitVC.hideInspectorToolbarBackground()
        }
    }
}

extension NSToolbarItem.Identifier {
    static let toggleFirstSidebarItem: NSToolbarItem.Identifier = NSToolbarItem.Identifier("ToggleFirstSidebarItem")
    static let toggleLastSidebarItem: NSToolbarItem.Identifier = NSToolbarItem.Identifier("ToggleLastSidebarItem")
    static let itemListTrackingSeparator = NSToolbarItem.Identifier("ItemListTrackingSeparator")
    static let branchPicker: NSToolbarItem.Identifier = NSToolbarItem.Identifier("BranchPicker")
}
