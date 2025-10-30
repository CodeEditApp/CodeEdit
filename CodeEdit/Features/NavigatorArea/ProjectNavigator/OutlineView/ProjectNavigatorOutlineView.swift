//
//  OutlineView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 05.04.22.
//

import SwiftUI
import Combine

/// Wraps an ``OutlineViewController`` inside a `NSViewControllerRepresentable`
struct ProjectNavigatorOutlineView: NSViewControllerRepresentable {

    @EnvironmentObject var workspace: WorkspaceDocument
    @EnvironmentObject var editorManager: EditorManager

    @StateObject var prefs: Settings = .shared

    typealias NSViewControllerType = ProjectNavigatorViewController

    func makeNSViewController(context: Context) -> ProjectNavigatorViewController {
        let controller = ProjectNavigatorViewController()
        controller.workspace = workspace
        controller.iconColor = prefs.preferences.general.fileIconStyle
        controller.editor = editorManager.activeEditor
        workspace.workspaceFileManager?.addObserver(context.coordinator)

        context.coordinator.controller = controller

        return controller
    }

    func updateNSViewController(_ nsViewController: ProjectNavigatorViewController, context: Context) {
        nsViewController.iconColor = prefs.preferences.general.fileIconStyle
        nsViewController.rowHeight = prefs.preferences.general.projectNavigatorSize.rowHeight
        nsViewController.fileExtensionsVisibility = prefs.preferences.general.fileExtensionsVisibility
        nsViewController.shownFileExtensions = prefs.preferences.general.shownFileExtensions
        nsViewController.hiddenFileExtensions = prefs.preferences.general.hiddenFileExtensions
        /// if the window becomes active from background, it will restore the selection to outline view.
        nsViewController.updateSelection(itemID: workspace.editorManager?.activeEditor.selectedTab?.file.id)
        return
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(workspace)
    }

    class Coordinator: NSObject, CEWorkspaceFileManagerObserver {
        init(_ workspace: WorkspaceDocument) {
            self.workspace = workspace
            super.init()

            workspace.listenerModel.$highlightedFileItem
                .sink(receiveValue: { [weak self] fileItem in
                    guard let fileItem else {
                        return
                    }
                    self?.controller?.reveal(fileItem)
                })
                .store(in: &cancellables)
            workspace.editorManager?.tabBarTabIdSubject
                .sink { [weak self] editorInstance in
                    self?.controller?.updateSelection(itemID: editorInstance?.file.id)
                }
                .store(in: &cancellables)
            workspace.$navigatorFilter
                .throttle(for: 0.1, scheduler: RunLoop.main, latest: true)
                .sink { [weak self] _ in
                    self?.controller?.handleFilterChange()
                }
                .store(in: &cancellables)
            Publishers.Merge(workspace.$sourceControlFilter, workspace.$sortFoldersOnTop)
                .throttle(for: 0.1, scheduler: RunLoop.main, latest: true)
                .sink { [weak self] _ in
                    self?.controller?.handleFilterChange()
                }
                .store(in: &cancellables)
        }

        var cancellables: Set<AnyCancellable> = []
        weak var workspace: WorkspaceDocument?
        weak var controller: ProjectNavigatorViewController?

        func fileManagerUpdated(updatedItems: Set<CEWorkspaceFile>) {
            guard let outlineView = controller?.outlineView else { return }
            let selectedRows = outlineView.selectedRowIndexes.compactMap({ outlineView.item(atRow: $0) })

            // Check if we're currently editing a phantom file and capture its text
            var editingPhantomFile: CEWorkspaceFile?
            var capturedText: String?
            var capturedSelectionRange: NSRange?

            if outlineView.window?.firstResponder !== outlineView
                && outlineView.window?.firstResponder is NSTextView
                && (outlineView.window?.firstResponder as? NSView)?.isDescendant(of: outlineView) == true {
                capturedSelectionRange = (outlineView.window?.firstResponder as? NSTextView)?.selectedRange

                // Find the cell being edited by traversing up from the text view
                var currentView = outlineView.window?.firstResponder as? NSView
                while let view = currentView {
                    if let cell = view as? ProjectNavigatorTableViewCell,
                       let fileItem = cell.fileItem, fileItem.phantomFile != nil {
                        editingPhantomFile = fileItem
                        capturedText = cell.textField?.stringValue
                        break
                    }
                    currentView = view.superview
                }
            }

            // Reload all items with children
            for item in updatedItems {
                outlineView.reloadItem(item, reloadChildren: true)
            }

            // Restore selected items where the files still exist.
            let selectedIndexes = selectedRows.compactMap({ outlineView.row(forItem: $0) }).filter({ $0 >= 0 })
            controller?.shouldSendSelectionUpdate = false
            outlineView.selectRowIndexes(IndexSet(selectedIndexes), byExtendingSelection: false)
            controller?.shouldSendSelectionUpdate = true

            // If we were editing a phantom file, restore the text field and focus
            if let phantomFile = editingPhantomFile, let text = capturedText {
                let row = outlineView.row(forItem: phantomFile)
                if row >= 0, let cell = outlineView.view(
                    atColumn: 0,
                    row: row,
                    makeIfNecessary: false
                ) as? ProjectNavigatorTableViewCell {
                    cell.textField?.stringValue = text
                    outlineView.window?.makeFirstResponder(cell.textField)
                    if let selectionRange = capturedSelectionRange {
                        cell.textField?.currentEditor()?.selectedRange = selectionRange
                    }
                }
            } else {
                // Reselect the file that is currently active in the editor so it still appears highlighted
                if selectedIndexes.isEmpty,
                   let activeFileID = workspace?.editorManager?.activeEditor.selectedTab?.file.id {
                    controller?.updateSelection(itemID: activeFileID)
                }
            }
        }

        deinit {
            workspace?.workspaceFileManager?.removeObserver(self)
        }
    }
}
