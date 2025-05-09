//
//  CodeEditWindowController.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 18.03.22.
//

import Cocoa
import SwiftUI
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

    var workspace: WorkspaceDocument?
    var workspaceSettingsWindow: NSWindow?
    var quickOpenPanel: SearchPanel?
    var commandPalettePanel: SearchPanel?
    var navigatorSidebarViewModel: NavigatorAreaViewModel?

    internal var cancellables = [AnyCancellable]()

    var splitViewController: CodeEditSplitViewController? {
        contentViewController as? CodeEditSplitViewController
    }

    init(
        window: NSWindow?,
        workspace: WorkspaceDocument?
    ) {
        super.init(window: window)
        window?.delegate = self
        guard let workspace else { return }
        self.workspace = workspace
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

    private func setupSplitView(with workspace: WorkspaceDocument) -> CodeEditSplitViewController? {
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
            windowRef: window
        )
    }

    private func getSelectedCodeFile() -> CodeFileDocument? {
        workspace?.editorManager?.activeEditor.selectedTab?.file.fileDocument
    }

    @IBAction func saveDocument(_ sender: Any) {
        guard let codeFile = getSelectedCodeFile() else { return }
        codeFile.save(sender)
        workspace?.editorManager?.activeEditor.temporaryTab = nil
    }

    @IBAction func openCommandPalette(_ sender: Any) {
        if let workspace, let state = workspace.commandsPaletteState {
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

    @IBAction func openQuickly(_ sender: Any?) {
        if let workspace, let state = workspace.openQuicklyViewModel {
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
                    workspace.editorManager?.openTab(item: file)
                }.environmentObject(workspace)

                panel.contentView = NSHostingView(rootView: SettingsInjector { contentView })
                window?.addChildWindow(panel, ordered: .above)
                panel.makeKeyAndOrderFront(self)
                self.panelOpen = true
            }
        }
    }

    @IBAction func closeCurrentTab(_ sender: Any) {
        if self.panelOpen { return }
        if (workspace?.editorManager?.activeEditor.tabs ?? []).isEmpty {
            self.closeActiveEditor(self)
        } else {
            workspace?.editorManager?.activeEditor.closeSelectedTab()
        }
    }

    @IBAction func closeActiveEditor(_ sender: Any) {
        if workspace?.editorManager?.editorLayout.findSomeEditor(
            except: workspace?.editorManager?.activeEditor
        ) == nil {
            NSApp.sendAction(#selector(NSWindow.performClose(_:)), to: NSApp.keyWindow, from: nil)
        } else {
            workspace?.editorManager?.activeEditor.close()
        }
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
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
        workspace = nil
        return true
    }

    var utilityAreaCollapsed: Bool {
        workspace?.utilityAreaModel?.isCollapsed ?? true
    }

    /// Returns `true` if at least one panel that was visible is still collapsed, meaning the interface is still hidden
    func isInterfaceStillHidden() -> Bool {
        // If the interface is already un-hidden, we can short-circuit.
        guard let prevNav = prevNavigatorCollapsed,
              let prevInsp = prevInspectorCollapsed,
              let prevUtil = prevUtilityAreaCollapsed,
              let prevTool = prevToolbarCollapsed
        else {
            return navigatorCollapsed && navigatorCollapsed && toolbarCollapsed && utilityAreaCollapsed
        }

        let stillHidden = (!prevNav && navigatorCollapsed)  ||
            (!prevInsp && inspectorCollapsed) ||
            (!prevUtil && utilityAreaCollapsed) ||
            (!prevTool && toolbarCollapsed)

        if !stillHidden { resetStoredInterfaceCollapseState() }

        // True when any panel that was previously visible is collapsed
        return stillHidden
    }

    /// Function for toggling the interface elements on or off
    ///
    /// - Parameter shouldHide: Pass `true` to hide all interface panels (and remember their current states),
    /// or `false` to restore them to how they were before hiding.
    func toggleInterface(shouldHide: Bool) {
        // When hiding, store how the interface looks now
        if shouldHide {
            storeInterfaceCollapseState()
        }

        // Determine the desired collapsed/visible state for every interface element
        let navigatorTargetState = determineDesiredCollapseState(
            shouldHide: shouldHide,
            currentlyCollapsed: navigatorCollapsed,
            previouslyCollapsed: prevNavigatorCollapsed,
        )
        let inspectorTargetState = determineDesiredCollapseState(
            shouldHide: shouldHide,
            currentlyCollapsed: inspectorCollapsed,
            previouslyCollapsed: prevInspectorCollapsed,
        )
        let utilityAreaTargetState = determineDesiredCollapseState(
            shouldHide: shouldHide,
            currentlyCollapsed: utilityAreaCollapsed,
            previouslyCollapsed: prevUtilityAreaCollapsed,
        )
        let toolbarTargetState = determineDesiredCollapseState(
            shouldHide: shouldHide,
            currentlyCollapsed: toolbarCollapsed,
            previouslyCollapsed: prevToolbarCollapsed,
        )

        // Toggle only the parts that need to change
        if navigatorCollapsed != navigatorTargetState {
            toggleFirstPanel(shouldAnimate: false)
        }
        if inspectorCollapsed != inspectorTargetState {
            toggleLastPanel(shouldAnimate: false)
        }
        if workspace?.utilityAreaModel?.isCollapsed != utilityAreaTargetState {
            CommandManager.shared.executeCommand("open.drawer")
        }
        if toolbarCollapsed != toolbarTargetState {
            toggleToolbar()
        }
    }

    /// Calculates the collapse state an interface element should have after a hide / show toggle.
    /// - Parameters:
    ///   - shouldHide: `true` when we’re hiding the whole interface.
    ///   - currentlyCollapsed: The panels current state
    ///   - previouslyCollapsed: The state we saved the last time we hid the UI, if any.
    /// - Returns: `true` for visible element, `false` for collapsed element
    func determineDesiredCollapseState(shouldHide: Bool, currentlyCollapsed: Bool, previouslyCollapsed: Bool?) -> Bool {
        // If ShouldHide, everything should close
        if shouldHide { return true }

        // If currently collapsed, and there is no previous state, show it.
        if previouslyCollapsed == nil && currentlyCollapsed { return false }

        // If currently visible and !shouldHide, it should not collapse.
        if !currentlyCollapsed && !shouldHide { return false }

        // If we have a previous state, return that one.
        if let remembered = previouslyCollapsed { return remembered }

        // If there is no stored state, return the current state.
        return currentlyCollapsed
    }

    /// Function for storing the current interface visibility states
    func storeInterfaceCollapseState() {
        prevNavigatorCollapsed = navigatorCollapsed
        prevInspectorCollapsed = inspectorCollapsed
        prevUtilityAreaCollapsed = workspace?.utilityAreaModel?.isCollapsed
        prevToolbarCollapsed = toolbarCollapsed
    }

    /// Function for resetting the stored interface visibility states
    func resetStoredInterfaceCollapseState() {
        prevNavigatorCollapsed = nil
        prevInspectorCollapsed = nil
        prevUtilityAreaCollapsed = nil
        prevToolbarCollapsed = nil
    }
}
