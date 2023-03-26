//
//  OutlineView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 05.04.22.
//

import SwiftUI
import Combine

/// Wraps an ``OutlineViewController`` inside a `NSViewControllerRepresentable`
struct OutlineView: NSViewControllerRepresentable {

    @EnvironmentObject
    var workspace: WorkspaceDocument

    @StateObject
    var prefs: AppPreferencesModel = .shared

    // This is mainly just used to trigger a view update.
    @Binding
    var selection: CEWorkspaceFile?

    typealias NSViewControllerType = OutlineViewController

    func makeNSViewController(context: Context) -> OutlineViewController {
        let controller = OutlineViewController()
        controller.workspace = workspace
        controller.iconColor = prefs.preferences.general.fileIconStyle
        workspace.workspaceFileManager?.onRefresh = {
            print("Refreshing!")
            print("\t" + (workspace.workspaceFileManager?.flattenedFileItems.map({
                "\($0.key): \($0.value.children?.map({ $0.name }) ?? [])"
            }).joined(separator: "\n\t") ?? "no items"))
            controller.outlineView.reloadData()
        }

        context.coordinator.controller = controller

        return controller
    }

    func updateNSViewController(_ nsViewController: OutlineViewController, context: Context) {
        nsViewController.iconColor = prefs.preferences.general.fileIconStyle
        nsViewController.rowHeight = prefs.preferences.general.projectNavigatorSize.rowHeight
        nsViewController.fileExtensionsVisibility = prefs.preferences.general.fileExtensionsVisibility
        nsViewController.shownFileExtensions = prefs.preferences.general.shownFileExtensions
        nsViewController.hiddenFileExtensions = prefs.preferences.general.hiddenFileExtensions
        nsViewController.updateSelection()
        return
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(workspace)
    }

    class Coordinator: NSObject {
        init(_ workspace: WorkspaceDocument) {
            self.workspace = workspace
            super.init()

            listener = workspace.listenerModel.$highlightedFileItem
                .sink(receiveValue: { [weak self] fileItem in
                guard let fileItem else {
                    return
                }
                self?.controller?.reveal(fileItem)
            })
        }

        var listener: AnyCancellable?
        var workspace: WorkspaceDocument
        var controller: OutlineViewController?

        deinit {
            listener?.cancel()
        }
    }
}
