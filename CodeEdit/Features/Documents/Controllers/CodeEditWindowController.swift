//
//  CodeEditWindowController.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 18.03.22.
//

import Cocoa
import SwiftUI
import Combine

final class CodeEditWindowController: NSWindowController, NSToolbarDelegate, ObservableObject {
    static let minSidebarWidth: CGFloat = 242

    @Published var navigatorCollapsed = false
    @Published var inspectorCollapsed = false

    private var taskManager = TaskManager()

    var observers: [NSKeyValueObservation] = []

    var workspace: WorkspaceDocument?
    var quickOpenPanel: OverlayPanel?
    var commandPalettePanel: OverlayPanel?
    var navigatorSidebarViewModel: NavigatorSidebarViewModel?

    var splitViewController: NSSplitViewController!

    internal var cancellables = [AnyCancellable]()

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

    deinit {
        cancellables.forEach({ $0.cancel() })
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSplitView(with workspace: WorkspaceDocument) {
        let feedbackPerformer = NSHapticFeedbackManager.defaultPerformer
        let splitVC = CodeEditSplitViewController(workspace: workspace, feedbackPerformer: feedbackPerformer)

        let navigatorViewModel = NavigatorSidebarViewModel()
        navigatorSidebarViewModel = navigatorViewModel

        let settingsView = SettingsInjector {
            NavigatorAreaView(workspace: workspace, viewModel: navigatorViewModel)
                .environmentObject(workspace)
                .environmentObject(workspace.editorManager)
        }

        let navigator = NSSplitViewItem(
            sidebarWithViewController: NSHostingController(rootView: settingsView)
        )
        navigator.titlebarSeparatorStyle = .none
        navigator.minimumThickness = Self.minSidebarWidth
        navigator.collapseBehavior = .useConstraints

        splitVC.addSplitViewItem(navigator)

        let workspaceView = SettingsInjector {
            WindowObserver(window: window!) {
                WorkspaceView()
                    .environmentObject(workspace)
                    .environmentObject(workspace.editorManager)
                    .environmentObject(workspace.utilityAreaModel)
            }
        }

        let mainContent = NSSplitViewItem(viewController: NSHostingController(rootView: workspaceView))
        mainContent.titlebarSeparatorStyle = .line
        mainContent.holdingPriority = .init(50)

        splitVC.addSplitViewItem(mainContent)

        let inspectorView = SettingsInjector {
            InspectorAreaView(viewModel: InspectorAreaViewModel())
                .environmentObject(workspace)
                .environmentObject(workspace.editorManager)
        }

        let inspector = NSSplitViewItem(viewController: NSHostingController(rootView: inspectorView))
        inspector.titlebarSeparatorStyle = .none
        inspector.minimumThickness = Self.minSidebarWidth
        inspector.isCollapsed = true
        inspector.canCollapse = true
        inspector.collapseBehavior = .useConstraints
        inspector.isSpringLoaded = true

        splitVC.addSplitViewItem(inspector)

        self.splitViewController = splitVC
        self.listenToDocumentEdited(workspace: workspace)
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
            // In Xcode tab bar style, we use default toolbar background with
            // line separator.
            self.window?.titlebarSeparatorStyle = .automatic
        }
        self.window?.toolbar = toolbar
    }

    // MARK: - Toolbar

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
            .addSidebarItem,
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
            .addSidebarItem
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
            return toolbarItem(
                identifier: itemIdentifier,
                label: "Navigator Sidebar",
                tooltip: "Hide or show the Navigator",
                icon: "sidebar.leading",
                action: #selector(self.toggleFirstPanel)
            )
        case .toggleLastSidebarItem:
            return toolbarItem(
                identifier: itemIdentifier,
                label: "Inspector Sidebar",
                tooltip: "Hide or show the Inspectors",
                icon: "sidebar.trailing",
                action: #selector(self.toggleLastPanel)
            )
        case .stopTaskSidebarItem:
            return toolbarItem(
                identifier: itemIdentifier,
                label: "Stop",
                tooltip: "Stop execution of task",
                icon: "stop.fill",
                action: nil
            )
        case .startTaskSidebarItem:
            return toolbarItem(
                identifier: itemIdentifier,
                label: "Start",
                tooltip: "Start execution of task",
                icon: "play.fill",
                action: #selector(self.runActiveTask)
            )
        case .addSidebarItem:
            return toolbarItem(
                identifier: itemIdentifier,
                label: "Add",
                tooltip: "Add",
                icon: "plus",
                action: nil
            )
        case .branchPicker:
            let toolbarItem = NSToolbarItem(itemIdentifier: .branchPicker)
            toolbarItem.view = NSHostingView(
                rootView: ToolbarBranchPicker(
                    workspaceFileManager: workspace?.workspaceFileManager
                )
            )
            return toolbarItem
        case .activityViewer:
            let toolbarItem = NSToolbarItem(itemIdentifier: .activityViewer)
            toolbarItem.view = NSHostingView(
                rootView: ActivityViewer(
                    workspaceFileManager: workspace?.workspaceFileManager,
                    taskManager: taskManager
                )
            )
            return toolbarItem
        default:
            return NSToolbarItem(itemIdentifier: itemIdentifier)
        }
    }

    private func toolbarItem(
        identifier: NSToolbarItem.Identifier,
        label: String,
        tooltip: String,
        icon: String,
        action: Selector?
    ) -> NSToolbarItem {
        let toolbarItem = NSToolbarItem(itemIdentifier: identifier)
        toolbarItem.label = label
        toolbarItem.paletteLabel = label
        toolbarItem.toolTip = tooltip
        toolbarItem.isBordered = true
        toolbarItem.target = self
        toolbarItem.action = action
        toolbarItem.image = NSImage(
            systemSymbolName: icon,
            accessibilityDescription: nil
        )?.withSymbolConfiguration(.init(scale: .large))

        return toolbarItem
    }

    @objc
    private func runActiveTask() {
        taskManager.executeActiveTask()
    }

    private func getSelectedCodeFile() -> CodeFileDocument? {
        workspace?.editorManager.activeEditor.selectedTab?.file.fileDocument
    }

    @IBAction func saveDocument(_ sender: Any) {
        guard let codeFile = getSelectedCodeFile() else { return }
        codeFile.save(sender)
        workspace?.editorManager.activeEditor.temporaryTab = nil
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
                    workspace.editorManager.openTab(item: file)
                }.environmentObject(workspace)

                panel.contentView = NSHostingView(rootView: SettingsInjector { contentView })
                window?.addChildWindow(panel, ordered: .above)
                panel.makeKeyAndOrderFront(self)
            }
        }
    }

    @IBAction func closeCurrentTab(_ sender: Any) {
        if (workspace?.editorManager.activeEditor.tabs ?? []).isEmpty {
            self.closeActiveEditor(self)
        } else {
            workspace?.editorManager.activeEditor.closeSelectedTab()
        }
    }

    @IBAction func closeActiveEditor(_ sender: Any) {
        if workspace?.editorManager.editorLayout.findSomeEditor(except: workspace?.editorManager.activeEditor) == nil {
            NSApp.sendAction(#selector(NSWindow.close), to: nil, from: nil)
        } else {
            workspace?.editorManager.activeEditor.close()
        }
    }
}
