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

    @StateObject var prefs: Settings = .shared

    typealias NSViewControllerType = ProjectNavigatorViewController

    func makeNSViewController(context: Context) -> ProjectNavigatorViewController {
        let controller = ProjectNavigatorViewController()
        controller.workspace = workspace
        controller.iconColor = prefs.preferences.general.fileIconStyle
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
        nsViewController.updateSelection(itemID: workspace.editorManager.activeEditor.selectedTab?.file.id)
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
            workspace.editorManager.tabBarTabIdSubject
                .sink { [weak self] itemID in
                    self?.controller?.updateSelection(itemID: itemID)
                }
                .store(in: &cancellables)
        }

        var cancellables: Set<AnyCancellable> = []
        var workspace: WorkspaceDocument
        var controller: ProjectNavigatorViewController?

        func fileManagerUpdated(updatedItems: Set<CEWorkspaceFile>) {
            guard let outlineView = controller?.outlineView else { return }

            for item in updatedItems {
                outlineView.reloadItem(item, reloadChildren: true)
            }

            controller?.updateSelection(itemID: workspace.editorManager.activeEditor.selectedTab?.file.id)
        }

        deinit {
            workspace.workspaceFileManager?.removeObserver(self)
        }
    }
}
