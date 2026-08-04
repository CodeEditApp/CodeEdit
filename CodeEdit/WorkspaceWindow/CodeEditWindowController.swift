//
//  CodeEditWindowController.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 18.03.22.
//

import Cocoa
import CodeEditDocument
import CodeEditSettings
import CEEditor
import CENotifications
import SwiftUI
import CodeEditUI
import Combine

final class CodeEditWindowController: NSWindowController, NSToolbarDelegate, ObservableObject, NSWindowDelegate {
    @Published var navigatorCollapsed: Bool = false
    @Published var inspectorCollapsed: Bool = false
    @Published var toolbarCollapsed: Bool = false

    // These variables store the state of the windows when using "Hide interface"
    @Published var prevNavigatorCollapsed: Bool?
    @Published var prevInspectorCollapsed: Bool?
    @Published var prevUtilityAreaCollapsed: Bool?
    @Published var prevToolbarCollapsed: Bool?

    private var panelOpen = false

    var observers: [NSKeyValueObservation] = []

    let dependencies: AppDependencies

    var workspace: Workspace?
    var workspaceSettingsWindow: NSWindow?
    var quickOpenPanel: SearchPanel?
    var commandPalettePanel: SearchPanel?
    var navigatorSidebarViewModel: NavigatorAreaViewModel?

    // Window-UI models: window-scoped state, owned here (1:1 with the workspace).
    let statusBarViewModel = StatusBarViewModel()
    let utilityAreaModel = UtilityAreaViewModel()
    let openQuicklyViewModel: OpenQuicklyViewModel
    let commandsPaletteState: QuickActionsViewModel
    let notificationPanel: NotificationPanelViewModel
    let taskNotificationHandler: TaskNotificationHandler

    internal var cancellables = [AnyCancellable]()

    var splitViewController: CodeEditSplitViewController? {
        contentViewController as? CodeEditSplitViewController
    }

    init(
        window: NSWindow?,
        workspace: Workspace,
        dependencies: AppDependencies
    ) {
        self.dependencies = dependencies
        self.workspace = workspace
        self.openQuicklyViewModel = OpenQuicklyViewModel(fileURL: workspace.fileURL)
        self.commandsPaletteState = QuickActionsViewModel(commandManager: dependencies.commandManager)
        self.notificationPanel = NotificationPanelViewModel(
            notificationManager: dependencies.notificationManager,
            eventBus: dependencies.eventBus
        )
        self.taskNotificationHandler = TaskNotificationHandler(
            workspaceURL: workspace.fileURL,
            eventBus: dependencies.eventBus
        )
        super.init(window: window)
        window?.delegate = self
        self.toolbarCollapsed = workspace.statePersistence.get(.toolbarCollapsed) as? Bool ?? false
        utilityAreaModel.restoreFromState(workspace.statePersistence)
        guard let splitViewController = setupSplitView(with: workspace) else {
            fatalError("Failed to set up content view.")
        }

        // Previous:
        // An NSHostingController is used, so the root viewController of the window is a SwiftUI-managed one.
        // This allows us to use some SwiftUI features, like focusedSceneObject.
        // -----
        // let view = CodeEditSplitView(controller: splitViewController).ignoresSafeArea()
        // contentViewController = NSHostingController(rootView: view)
        // -----
        //
        // New:
        // The previous decision led to a very jank split controller mechanism because SwiftUI's layout system is not
        // very compatible with AppKit's when it comes to the inspector/navigator toolbar & split view system.
        // -----
        contentViewController = splitViewController
        // -----

        observers = [
            splitViewController.splitViewItems.first!.observe(\.isCollapsed, changeHandler: { [weak self] item, _ in
                self?.navigatorCollapsed = item.isCollapsed
            }),
            splitViewController.splitViewItems.last!.observe(\.isCollapsed, changeHandler: { [weak self] item, _ in
                self?.inspectorCollapsed = item.isCollapsed
            })
        ]

        setupToolbar()
        updateToolbarVisibility()
        registerCommands()
    }

    deinit {
        cancellables.forEach({ $0.cancel() })
        cancellables.removeAll()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSplitView(with workspace: Workspace) -> CodeEditSplitViewController? {
        guard let window else {
            assertionFailure("No window found for this controller. Cannot set up content.")
            return nil
        }

        let navigatorModel = NavigatorAreaViewModel()
        navigatorSidebarViewModel = navigatorModel
        self.listenToDocumentEdited(workspace: workspace)
        return CodeEditSplitViewController(
            workspace: workspace,
            navigatorViewModel: navigatorModel,
            windowRef: window,
            dependencies: dependencies,
            statusBarViewModel: statusBarViewModel,
            utilityAreaModel: utilityAreaModel,
            notificationPanel: notificationPanel
        )
    }

    private func getSelectedCodeFile() -> CodeFileDocument? {
        guard let editorManager = workspace?.editorManager,
              let file = editorManager.activeEditor.selectedTab?.file else { return nil }
        return editorManager.document(for: file)
    }

    @IBAction func saveDocument(_ sender: Any) {
        guard let codeFile = getSelectedCodeFile() else { return }
        codeFile.save(sender)
        workspace?.editorManager.activeEditor.temporaryTab = nil
    }

    @IBAction func openCommandPalette(_ sender: Any) {
        do {
            let state = commandsPaletteState
            if let commandPalettePanel {
                if commandPalettePanel.isKeyWindow {
                    commandPalettePanel.close()
                    self.panelOpen = false
                    state.reset()
                    return
                } else {
                    state.reset()
                    window?.addChildWindow(commandPalettePanel, ordered: .above)
                    commandPalettePanel.makeKeyAndOrderFront(self)
                    self.panelOpen = true
                }
            } else {
                let panel = SearchPanel()
                self.commandPalettePanel = panel
                let contentView = QuickActionsView(state: state) {
                    panel.close()
                    self.panelOpen = false
                }
                panel.contentView = NSHostingView(rootView: SettingsInjector { contentView })
                window?.addChildWindow(panel, ordered: .above)
                panel.makeKeyAndOrderFront(self)
                self.panelOpen = true
            }
        }
    }

    /// Opens the search navigator and focuses the search field
    @IBAction func openSearchNavigator(_ sender: Any? = nil) {
        if navigatorCollapsed {
            toggleFirstPanel()
        }

        if let navigatorViewModel = navigatorSidebarViewModel,
           let searchTab = navigatorViewModel.tabItems.first(where: { $0 == .search }) {
            DispatchQueue.main.async {
                self.workspace?.searchState.shouldFocusSearchField = true
                navigatorViewModel.setNavigatorTab(tab: searchTab)
            }
        }
    }

    @IBAction func openQuickly(_ sender: Any?) {
        if let workspace {
            let state = openQuicklyViewModel
            if let quickOpenPanel {
                if quickOpenPanel.isKeyWindow {
                    quickOpenPanel.close()
                    self.panelOpen = false
                    return
                } else {
                    window?.addChildWindow(quickOpenPanel, ordered: .above)
                    quickOpenPanel.makeKeyAndOrderFront(self)
                    self.panelOpen = true
                }
            } else {
                let panel = SearchPanel()
                self.quickOpenPanel = panel

                let contentView = OpenQuicklyView(state: state) {
                    panel.close()
                    self.panelOpen = false
                } openFile: { file in
                    workspace.editorManager.openTab(item: file)
                }
                .environment(\.workspaceFileManager, workspace.workspaceFileManager)
                .environment(\.workspaceFileProvider, workspace.workspaceFileManager)
                .environment(\.filePreview) { file in AnyView(FilePreviewView(item: file)) }
                .environment(\.languageServices, dependencies.languageServicesProvider)
                .environment(\.currentTheme, ThemeModel.shared.selectedTheme ?? ThemeModel.shared.themes.first!)

                panel.contentView = NSHostingView(rootView: SettingsInjector { contentView })
                window?.addChildWindow(panel, ordered: .above)
                panel.makeKeyAndOrderFront(self)
                self.panelOpen = true
            }
        }
    }

    @IBAction func closeCurrentTab(_ sender: Any) {
        if self.panelOpen { return }
        if (workspace?.editorManager.activeEditor.tabs ?? []).isEmpty {
            self.closeActiveEditor(self)
        } else {
            workspace?.editorManager.activeEditor.closeSelectedTab()
        }
    }

    @IBAction func closeActiveEditor(_ sender: Any) {
        if workspace?.editorManager.editorLayout.findSomeEditor(
            except: workspace?.editorManager.activeEditor
        ) == nil {
            NSApp.sendAction(#selector(NSWindow.performClose(_:)), to: NSApp.keyWindow, from: nil)
        } else {
            workspace?.editorManager.activeEditor.close()
        }
    }

    @IBAction func openWorkspaceSettings(_ sender: Any) {
        guard let window = window,
              let workspace = workspace
        else { return }
        let workspaceSettingsManager = workspace.workspaceSettingsManager
        let taskManager = workspace.taskManager

        if let workspaceSettingsWindow, workspaceSettingsWindow.isVisible {
            workspaceSettingsWindow.makeKeyAndOrderFront(self)
        } else {
            let settingsWindow = NSWindow()
            self.workspaceSettingsWindow = settingsWindow
            let contentView = WorkspaceSettingsView(
                dismiss: { [weak self, weak settingsWindow] in
                    guard let settingsWindow else { return }
                    self?.window?.endSheet(settingsWindow)
                 }
            )
            .environmentObject(workspaceSettingsManager)
            .environmentObject(taskManager)

            settingsWindow.contentView = NSHostingView(rootView: contentView)
            settingsWindow.titlebarAppearsTransparent = true
            settingsWindow.setContentSize(NSSize(width: 515, height: 515))
            settingsWindow.setAccessibilityTitle("Workspace Settings")

            window.beginSheet(settingsWindow, completionHandler: nil)
        }
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // Check for unsaved changes before closing
        if let workspace, workspace.hasUnsavedChanges() {
            guard workspace.promptSaveUnsavedFiles() else {
                return false // User cancelled
            }
        }

        cancellables.forEach({ $0.cancel() })
        cancellables.removeAll()

        for _ in 0..<(splitViewController?.children.count ?? 0) {
            splitViewController?.removeChild(at: 0)
        }
        contentViewController?.removeFromParent()
        contentViewController = nil

        workspaceSettingsWindow?.close()
        workspaceSettingsWindow = nil
        quickOpenPanel = nil
        commandPalettePanel = nil
        navigatorSidebarViewModel = nil

        // Notify the window manager to clean up workspace state
        if let workspace {
            utilityAreaModel.saveRestorationState(workspace.statePersistence)
            dependencies.workspaceWindowManager.closeWorkspace(workspace)
        }
        workspace = nil
        return true
    }
}
