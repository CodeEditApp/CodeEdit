//
//  CodeEditSplitViewController.swift
//  CodeEdit
//
//  Created by YAPRYNTSEV Aleksey on 31.12.2022.
//

import Cocoa
import CodeEditCore
import CodeEditUI
import CEEditor
import SwiftUI
import CENotifications

final class CodeEditSplitViewController: NSSplitViewController {
    static let minSidebarWidth: CGFloat = 242
    static let maxSnapWidth: CGFloat = snapWidth + 10
    static let snapWidth: CGFloat = 272
    static let minSnapWidth: CGFloat = snapWidth - 10

    private let dependencies: AppDependencies

    private weak var workspace: Workspace?
    private weak var navigatorViewModel: NavigatorAreaViewModel?
    private weak var windowRef: NSWindow?
    private weak var statePersistence: (any WorkspaceStatePersisting)?
    private unowned var hapticPerformer: NSHapticFeedbackPerformer

    // Window-UI models, owned by the window controller and injected here for the SwiftUI trees.
    private let statusBarViewModel: StatusBarViewModel
    private let utilityAreaModel: UtilityAreaViewModel
    private let notificationPanel: NotificationPanelViewModel

    /// Per-window active-file read-model, retained so its Combine subscription lives with the window.
    private var activeEditorState: AppActiveEditorState?

    /// Per-window active-cursor read-model, retained so its Combine subscription lives with the window.
    private var activeCursorState: AppActiveCursorState?

    /// Per-window file-override read/write seam, retained for the window's lifetime.
    private var fileEditorOverrides: AppFileEditorOverrides?

    // MARK: - Initialization

    init(
        workspace: Workspace,
        navigatorViewModel: NavigatorAreaViewModel,
        windowRef: NSWindow,
        dependencies: AppDependencies,
        statusBarViewModel: StatusBarViewModel,
        utilityAreaModel: UtilityAreaViewModel,
        notificationPanel: NotificationPanelViewModel,
        hapticPerformer: NSHapticFeedbackPerformer = NSHapticFeedbackManager.defaultPerformer
    ) {
        self.dependencies = dependencies
        self.workspace = workspace
        self.navigatorViewModel = navigatorViewModel
        self.windowRef = windowRef
        self.statePersistence = workspace.statePersistence
        self.statusBarViewModel = statusBarViewModel
        self.utilityAreaModel = utilityAreaModel
        self.notificationPanel = notificationPanel
        self.hapticPerformer = hapticPerformer
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let windowRef else {
            // swiftlint:disable:next line_length
            assertionFailure("No WindowRef found, not initialized properly or the window was dereferenced and the controller was not.")
            return
        }

        guard let workspace, let navigatorViewModel else {
            assertionFailure("Missing workspace=\(workspace == nil) or navigator=\(navigatorViewModel == nil)")
            return
        }

        splitView.translatesAutoresizingMaskIntoConstraints = false

        let activeEditorState = AppActiveEditorState(editorManager: workspace.editorManager)
        self.activeEditorState = activeEditorState

        let activeCursorState = AppActiveCursorState(editorManager: workspace.editorManager)
        self.activeCursorState = activeCursorState

        let fileEditorOverrides = AppFileEditorOverrides(editorManager: workspace.editorManager)
        self.fileEditorOverrides = fileEditorOverrides

        addSplitViewItem(makeNavigatorItem(
            workspace: workspace,
            navigatorViewModel: navigatorViewModel,
            activeEditorState: activeEditorState
        ))
        addSplitViewItem(makeMainContentItem(
            workspace: workspace,
            windowRef: windowRef,
            activeEditorState: activeEditorState,
            activeCursorState: activeCursorState
        ))
        addSplitViewItem(makeInspectorItem(
            workspace: workspace,
            activeEditorState: activeEditorState,
            fileEditorOverrides: fileEditorOverrides
        ))
    }

    private func makeNavigatorItem(
        workspace: Workspace,
        navigatorViewModel: NavigatorAreaViewModel,
        activeEditorState: AppActiveEditorState
    ) -> NSSplitViewItem {
        makeNavigator(view: SettingsInjector(store: dependencies.settingsStore) {
            NavigatorAreaView(viewModel: navigatorViewModel)
                .environment(\.workspace, workspace)
                .environmentObject(workspace.editorManager)
                .environmentObject(workspace.projectNavigatorViewModel)
                .environmentObject(workspace.sourceControlManager)
                .environmentObject(workspace.sourceControlViewModel)
                .environmentObject(workspace.searchState)
                .environment(\.workspaceFileManager, workspace.workspaceFileManager)
                .environment(\.workspaceFileProvider, workspace.workspaceFileManager)
                .environment(\.workspaceFileURL, workspace.fileURL)
                .environment(\.activeEditorState, activeEditorState)
                .appServices(dependencies)
        })
    }

    private func makeMainContentItem(
        workspace: Workspace,
        windowRef: NSWindow,
        activeEditorState: AppActiveEditorState,
        activeCursorState: AppActiveCursorState
    ) -> NSSplitViewItem {
        let workspaceView = SettingsInjector(store: dependencies.settingsStore) {
            WindowObserver(window: WindowBox(value: windowRef)) {
                WorkspaceView()
                    .environmentObject(workspace.editorManager)
                    .environmentObject(statusBarViewModel)
                    .environmentObject(utilityAreaModel)
                    .environmentObject(workspace.taskManager)
                    .environmentObject(workspace.sourceControlManager)
                    .environmentObject(workspace.sourceControlViewModel)
                    .environmentObject(workspace.undoRegistration)
                    .environmentObject(notificationPanel)
                    .environment(\.workspaceFileManager, workspace.workspaceFileManager)
                    .environment(\.workspaceFileProvider, workspace.workspaceFileManager)
                    .environment(\.workspaceFileURL, workspace.fileURL)
                    .environment(\.workspaceStatePersistence, workspace.statePersistence)
                    .environment(\.activeEditorState, activeEditorState)
                    .environment(\.activeCursorState, activeCursorState)
                    .appServices(dependencies)
            }
        }

        let mainContent = NSSplitViewItem(viewController: NSHostingController(rootView: workspaceView))
        mainContent.titlebarSeparatorStyle = .line
        mainContent.minimumThickness = 200
        return mainContent
    }

    private func makeInspectorItem(
        workspace: Workspace,
        activeEditorState: AppActiveEditorState,
        fileEditorOverrides: AppFileEditorOverrides
    ) -> NSSplitViewItem {
        makeInspector(view: SettingsInjector(store: dependencies.settingsStore) {
            InspectorAreaView(viewModel: InspectorAreaViewModel())
                .environmentObject(workspace.editorManager)
                .environmentObject(workspace.sourceControlManager)
                .environment(\.workspaceFileManager, workspace.workspaceFileManager)
                .environment(\.workspaceFileProvider, workspace.workspaceFileManager)
                .environment(\.activeEditorState, activeEditorState)
                .environment(\.fileEditorOverrides, fileEditorOverrides)
                .appServices(dependencies)
        })
    }

    private func makeNavigator(view: some View) -> NSSplitViewItem {
        let navigator = NSSplitViewItem(sidebarWithViewController: NSHostingController(rootView: view))
        if #unavailable(macOS 26) {
            navigator.titlebarSeparatorStyle = .none
        }
        navigator.isSpringLoaded = true
        navigator.minimumThickness = Self.minSidebarWidth
        navigator.collapseBehavior = .useConstraints
        return navigator
    }

    private func makeInspector(view: some View) -> NSSplitViewItem {
        let inspector = NSSplitViewItem(inspectorWithViewController: NSHostingController(rootView: view))
        inspector.titlebarSeparatorStyle = .none
        inspector.minimumThickness = Self.minSidebarWidth
        inspector.maximumThickness = .greatestFiniteMagnitude
        inspector.collapseBehavior = .useConstraints
        inspector.isSpringLoaded = true
        return inspector
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        let navigatorWidth = statePersistence?.get(.splitViewWidth) as? CGFloat
        splitView.setPosition(navigatorWidth ?? Self.minSidebarWidth, ofDividerAt: 0)

        if let firstSplitView = splitViewItems.first {
            firstSplitView.isCollapsed = statePersistence?.get(
                .navigatorCollapsed
            ) as? Bool ?? false
        }

        if let lastSplitView = splitViewItems.last {
            lastSplitView.isCollapsed = statePersistence?.get(
                .inspectorCollapsed
            ) as? Bool ?? true
        }

        notificationPanel.updateToolbarItem()
    }

    // MARK: - NSSplitViewDelegate

    /// Perform the spring loaded navigator splits.
    /// - Note: This could be removed. The only additional functionality this provides over using just the
    ///         `NSSplitViewItem.isSpringLoaded` & `NSSplitViewItem.minimumThickness` is the haptic feedback we add.
    /// - Parameters:
    ///   - splitView: The split view to use.
    ///   - proposedPosition: The proposed drag position.
    ///   - dividerIndex: The index of the divider being dragged.
    /// - Returns: The position to move the divider to.
    override func splitView(
        _ splitView: NSSplitView,
        constrainSplitPosition proposedPosition: CGFloat,
        ofSubviewAt dividerIndex: Int
    ) -> CGFloat {
        switch dividerIndex {
        case 0:
            // Navigator
            if (Self.minSnapWidth...Self.maxSnapWidth).contains(proposedPosition) {
                return Self.snapWidth
            } else if proposedPosition <= Self.minSidebarWidth / 2 {
                hapticCollapse(splitViewItems.first, collapseAction: true)
                return 0
            } else {
                hapticCollapse(splitViewItems.first, collapseAction: false)
                return max(Self.minSidebarWidth, proposedPosition)
            }
        case 1:
            let proposedWidth = view.frame.width - proposedPosition
            if proposedWidth <= Self.minSidebarWidth / 2 {
                hapticCollapse(splitViewItems.last, collapseAction: true)
                return proposedPosition
            } else {
                hapticCollapse(splitViewItems.last, collapseAction: false)
                return min(view.frame.width - Self.minSidebarWidth, proposedPosition)
            }
        default:
            return proposedPosition
        }
    }

    /// Performs a haptic feedback while collapsing or revealing a split item.
    /// If the item was not previously in the new intended state, a haptic `.alignment` feedback is sent.
    /// - Parameters:
    ///   - item: The item to collapse or reveal
    ///   - collapseAction: Whether or not to collapse the item. Set to true to collapse it.
    private func hapticCollapse(_ item: NSSplitViewItem?, collapseAction: Bool) {
        if item?.isCollapsed == !collapseAction {
            hapticPerformer.perform(.alignment, performanceTime: .now)
        }
        item?.isCollapsed = collapseAction
    }

    /// Save the width of the inspector and navigator between sessions.
    override func splitViewDidResizeSubviews(_ notification: Notification) {
        super.splitViewDidResizeSubviews(notification)
        guard let resizedDivider = notification.userInfo?["NSSplitViewDividerIndex"] as? Int else {
            return
        }

        if resizedDivider == 0 {
            let panel = splitView.subviews[0]
            let width = panel.frame.size.width
            if width > 0 {
                statePersistence?.set(key: .splitViewWidth, value: width)
            }
        }
    }

    func saveNavigatorCollapsedState(isCollapsed: Bool) {
        statePersistence?.set(key: .navigatorCollapsed, value: isCollapsed)
    }

    func saveInspectorCollapsedState(isCollapsed: Bool) {
        statePersistence?.set(key: .inspectorCollapsed, value: isCollapsed)
    }
}
