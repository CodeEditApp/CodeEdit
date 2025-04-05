//
//  IssueNavigatorOutlineView.swift
//  CodeEdit
//
//  Created by Abe Malla on 3/16/25.
//

import SwiftUI
import Combine

/// Wraps an ``OutlineViewController`` inside a `NSViewControllerRepresentable`
struct IssueNavigatorOutlineView: NSViewControllerRepresentable {

    @EnvironmentObject var workspace: WorkspaceDocument
    @EnvironmentObject var editorManager: EditorManager

    @StateObject var prefs: Settings = .shared

    typealias NSViewControllerType = IssueNavigatorViewController

    func makeNSViewController(context: Context) -> IssueNavigatorViewController {
        let controller = IssueNavigatorViewController()
        controller.workspace = workspace
        controller.editor = editorManager.activeEditor

        context.coordinator.controller = controller
        context.coordinator.setupObservers()

        return controller
    }

    func updateNSViewController(_ nsViewController: IssueNavigatorViewController, context: Context) {
        nsViewController.rowHeight = prefs.preferences.general.projectNavigatorSize.rowHeight
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(workspace: workspace)
    }

    class Coordinator: NSObject {
        var cancellables = Set<AnyCancellable>()
        weak var workspace: WorkspaceDocument?
        weak var controller: IssueNavigatorViewController?

        init(workspace: WorkspaceDocument?) {
            self.workspace = workspace
            super.init()
        }

        func setupObservers() {
            guard let viewModel = workspace?.issueNavigatorViewModel else { return }

            viewModel.diagnosticsDidChangePublisher
                .sink { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.controller?.outlineView.reloadData()
                    }
                }
                .store(in: &cancellables)
        }
    }
}
