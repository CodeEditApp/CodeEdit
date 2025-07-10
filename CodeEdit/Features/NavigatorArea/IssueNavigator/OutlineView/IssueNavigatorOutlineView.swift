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

        // Update the controller reference if needed
        if nsViewController.workspace !== workspace {
            nsViewController.workspace = workspace
            context.coordinator.workspace = workspace
            context.coordinator.setupObservers()
        }
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
            // Cancel existing subscriptions
            cancellables.removeAll()

            guard let viewModel = workspace?.diagnosticsManager else { return }

            // Listen for diagnostic changes
            viewModel.diagnosticsDidChangePublisher
                .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let controller = self?.controller else { return }

                    // Save current selection
                    let selectedRows = controller.outlineView.selectedRowIndexes

                    // Reload data
                    controller.outlineView.reloadData()

                    // Restore expansion state after reload
                    controller.restoreExpandedState()

                    // Restore selection if possible
                    if !selectedRows.isEmpty {
                        controller.outlineView.selectRowIndexes(selectedRows, byExtendingSelection: false)
                    }
                }
                .store(in: &cancellables)

            // Listen for filter changes
            viewModel.$filterOptions
                .dropFirst() // Skip initial value
                .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let controller = self?.controller else { return }

                    controller.outlineView.reloadData()
                    controller.restoreExpandedState()
                }
                .store(in: &cancellables)
        }

        deinit {
            cancellables.removeAll()
        }
    }
}
