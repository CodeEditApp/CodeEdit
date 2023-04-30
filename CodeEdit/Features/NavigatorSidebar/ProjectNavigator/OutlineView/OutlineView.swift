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

    // This is mainly just used to trigger a view update.
    @Binding
    var selection: WorkspaceClient.FileItem?

    typealias NSViewControllerType = OutlineViewController

    func makeNSViewController(context: Context) -> OutlineViewController {
        let controller = OutlineViewController()
        controller.workspace = workspace
        controller.iconColor = Settings[\.general].fileIconStyle

        context.coordinator.controller = controller

        return controller
    }

    func updateNSViewController(_ nsViewController: OutlineViewController, context: Context) {
        nsViewController.iconColor = Settings[\.general].fileIconStyle
        nsViewController.rowHeight = Settings[\.general].projectNavigatorSize.rowHeight
        nsViewController.fileExtensionsVisibility = Settings[\.general].fileExtensionsVisibility
        nsViewController.shownFileExtensions = Settings[\.general].shownFileExtensions
        nsViewController.hiddenFileExtensions = Settings[\.general].hiddenFileExtensions
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
