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

    @AppSettings var settings

    // This is mainly just used to trigger a view update.
    @Binding
    var selection: WorkspaceClient.FileItem?

    typealias NSViewControllerType = OutlineViewController

    func makeNSViewController(context: Context) -> OutlineViewController {
        let controller = OutlineViewController()
        controller.workspace = workspace
        controller.iconColor = settings.general.fileIconStyle

        context.coordinator.controller = controller

        return controller
    }

    func updateNSViewController(_ nsViewController: OutlineViewController, context: Context) {
        nsViewController.iconColor = settings.general.fileIconStyle
        nsViewController.rowHeight = settings.general.projectNavigatorSize.rowHeight
        nsViewController.fileExtensionsVisibility = settings.general.fileExtensionsVisibility
        nsViewController.shownFileExtensions = settings.general.shownFileExtensions
        nsViewController.hiddenFileExtensions = settings.general.hiddenFileExtensions
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
