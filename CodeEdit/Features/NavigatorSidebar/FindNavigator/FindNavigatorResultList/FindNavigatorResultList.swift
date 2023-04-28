//
//  SearchResultList.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/22.
//

import SwiftUI
import Combine

struct FindNavigatorResultList: NSViewControllerRepresentable {

    @EnvironmentObject
    var workspace: WorkspaceDocument

    @AppSettings var settings

    typealias NSViewControllerType = FindNavigatorListViewController

    func makeNSViewController(context: Context) -> FindNavigatorListViewController {
        let controller = FindNavigatorListViewController(workspace: workspace)
        controller.setSearchResults(workspace.searchState?.searchResult ?? [])
        controller.rowHeight = settings.general.projectNavigatorSize.rowHeight
        context.coordinator.controller = controller
        return controller
    }

    func updateNSViewController(_ nsViewController: FindNavigatorListViewController, context: Context) {
        nsViewController.updateNewSearchResults(
            workspace.searchState?.searchResult ?? [],
            searchId: workspace.searchState?.searchId
        )
        if nsViewController.rowHeight != settings.general.projectNavigatorSize.rowHeight {
            nsViewController.rowHeight = settings.general.projectNavigatorSize.rowHeight
        }
        return
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            state: workspace.searchState,
            controller: nil
        )
    }

    class Coordinator: NSObject {
        init(state: WorkspaceDocument.SearchState?, controller: FindNavigatorListViewController?) {
            self.controller = controller
            super.init()
            self.listener = state?
                .searchResult
                .publisher
                .receive(on: RunLoop.main)
                .collect()
                .sink(receiveValue: { [weak self] searchResults in
                    self?.controller?.updateNewSearchResults(searchResults, searchId: state?.searchId)
                })
        }

        var listener: AnyCancellable?
        var controller: FindNavigatorListViewController?

        deinit {
            controller = nil
            listener?.cancel()
            listener = nil
        }
    }
}
