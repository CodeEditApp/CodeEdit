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

    @EnvironmentObject
    var workspace: WorkspaceDocument

    @StateObject
    var prefs: Settings = .shared

    typealias NSViewControllerType = ProjectNavigatorViewController

    func makeNSViewController(context: Context) -> ProjectNavigatorViewController {
        let controller = ProjectNavigatorViewController()
        controller.workspace = workspace
        controller.iconColor = prefs.preferences.general.fileIconStyle
        workspace.onRefresh = {
            print("Refreshing!!!")
            controller.outlineView.reloadData()
            controller.updateSelection(itemID: workspace.tabManager.activeTabGroup.selected?.id)
        }
//        workspace.workspaceFileManager?.onRefresh = {
//            controller.outlineView.reloadData()
//            controller.updateSelection(itemID: workspace.tabManager.activeTabGroup.selected?.id)
//        }
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
        nsViewController.updateSelection(itemID: workspace.tabManager.activeTabGroup.selected?.id)
        return
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(workspace)
    }

    class Coordinator: NSObject {
        init(_ workspace: WorkspaceDocument) {
            self.workspace = workspace
            super.init()

            // FIXME: 
//            workspace.listenerModel.$highlightedFileItem
//                .sink(receiveValue: { [weak self] fileItem in
//                    guard let fileItem else {
//                        return
//                    }
//                    self?.controller?.reveal(fileItem)
//                })
//                .store(in: &cancellables)
            workspace.tabManager.tabBarItemIdSubject
                .sink { [weak self] itemID in
                    self?.controller?.updateSelection(itemID: itemID)
                }
                .store(in: &cancellables)
        }

        var cancellables: Set<AnyCancellable> = []
        var workspace: WorkspaceDocument
        var controller: ProjectNavigatorViewController?

    }
}
