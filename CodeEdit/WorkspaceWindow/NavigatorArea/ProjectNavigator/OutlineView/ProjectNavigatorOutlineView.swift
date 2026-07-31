//
//  OutlineView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 05.04.22.
//

import SwiftUI
import CEWorkspaceFileManager
import CodeEditCore
import CodeEditSettings
import CEEditor
import Combine

/// Wraps an ``OutlineViewController`` inside a `NSViewControllerRepresentable`
struct ProjectNavigatorOutlineView: NSViewControllerRepresentable {

    @EnvironmentObject var workspace: Workspace
    @EnvironmentObject var editorManager: EditorManager

    @Environment(\.activeEditorState)
    private var activeEditorState
    @Environment(\.workspaceNavigator)
    private var workspaceNavigator

    @StateObject var prefs: CodeEditSettings.Settings = .shared

    typealias NSViewControllerType = ProjectNavigatorViewController

    func makeNSViewController(context: Context) -> ProjectNavigatorViewController {
        let controller = ProjectNavigatorViewController()
        controller.workspace = workspace
        controller.iconColor = prefs.preferences.general.fileIconStyle
        controller.activeEditorState = activeEditorState
        controller.workspaceNavigator = workspaceNavigator
        workspace.workspaceFileManager.addObserver(context.coordinator)

        context.coordinator.controller = controller
        context.coordinator.observeActiveFile(activeEditorState)

        return controller
    }

    func updateNSViewController(_ nsViewController: ProjectNavigatorViewController, context: Context) {
        nsViewController.iconColor = prefs.preferences.general.fileIconStyle
        nsViewController.rowHeight = prefs.preferences.general.projectNavigatorSize.rowHeight
        nsViewController.fileExtensionsVisibility = prefs.preferences.general.fileExtensionsVisibility
        nsViewController.shownFileExtensions = prefs.preferences.general.shownFileExtensions
        nsViewController.hiddenFileExtensions = prefs.preferences.general.hiddenFileExtensions
        /// if the window becomes active from background, it will restore the selection to outline view.
        nsViewController.updateSelection(itemID: activeEditorState.selectedFile?.id)
        return
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(workspace)
    }

    @MainActor
    class Coordinator: NSObject, WorkspaceFileObserver {
        init(_ workspace: Workspace) {
            self.workspace = workspace
            self.fileManager = workspace.workspaceFileManager
            super.init()

            workspace.revealRequests
                .sink(receiveValue: { [weak self] file in
                    self?.controller?.reveal(file)
                })
                .store(in: &cancellables)
            do {
                let projectNavigatorViewModel = workspace.projectNavigatorViewModel
                projectNavigatorViewModel.$navigatorFilter
                    .throttle(for: 0.1, scheduler: RunLoop.main, latest: true)
                    .sink { [weak self] _ in
                        self?.controller?.handleFilterChange()
                    }
                    .store(in: &cancellables)
                Publishers.Merge(
                    projectNavigatorViewModel.$sourceControlFilter,
                    projectNavigatorViewModel.$sortFoldersOnTop
                )
                    .throttle(for: 0.1, scheduler: RunLoop.main, latest: true)
                    .sink { [weak self] _ in
                        self?.controller?.handleFilterChange()
                    }
                    .store(in: &cancellables)
            }
        }

        var cancellables: Set<AnyCancellable> = []
        private var selectionCancellable: AnyCancellable?
        weak var workspace: Workspace?
        weak var fileManager: CEWorkspaceFileManager?
        weak var controller: ProjectNavigatorViewController?

        /// Subscribe to the active-file read-model so the outline highlights the active file.
        /// Wired from `makeNSViewController`, where the `@Environment` value is reliably populated.
        func observeActiveFile(_ state: ActiveEditorState) {
            // React to *changes* only. `selectedFilePublisher` is a `CurrentValueSubject` that
            // replays the current value on subscribe; skip it so we don't call `updateSelection`
            // (which touches the IUO `outlineView`) during `makeNSViewController`, before the view
            // has loaded. The initial selection is set by `updateNSViewController`.
            selectionCancellable = state.selectedFilePublisher
                .dropFirst()
                .sink { [weak self] file in
                    self?.controller?.updateSelection(itemID: file?.id)
                }
        }

        func fileManagerUpdated(updatedItems: Set<CEWorkspaceFile>) {
            guard let outlineView = controller?.outlineView else { return }
            let selectedRows = outlineView.selectedRowIndexes.compactMap({ outlineView.item(atRow: $0) })

            // If some text view inside the outline view is first responder right now, push the update off
            // until editing is finished using the `shouldReloadAfterDoneEditing` flag.
            if outlineView.window?.firstResponder !== outlineView
                && outlineView.window?.firstResponder is NSTextView
                && (outlineView.window?.firstResponder as? NSView)?.isDescendant(of: outlineView) == true {
                controller?.shouldReloadAfterDoneEditing = true
            } else {
                for item in updatedItems {
                    outlineView.reloadItem(item, reloadChildren: true)
                }
            }

            // Restore selected items where the files still exist.
            let selectedIndexes = selectedRows.compactMap({ outlineView.row(forItem: $0) }).filter({ $0 >= 0 })
            controller?.shouldSendSelectionUpdate = false
            outlineView.selectRowIndexes(IndexSet(selectedIndexes), byExtendingSelection: false)
            controller?.shouldSendSelectionUpdate = true
        }

        deinit {
            fileManager?.removeObserver(self)
        }
    }
}
