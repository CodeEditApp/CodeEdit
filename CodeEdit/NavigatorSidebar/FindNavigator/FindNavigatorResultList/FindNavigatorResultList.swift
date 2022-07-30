//
//  SearchResultList.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/22.
//

import SwiftUI
import WorkspaceClient
import AppPreferences
import Search
import Combine

struct FindNavigatorResultList: NSViewControllerRepresentable {

    @StateObject
    var workspace: WorkspaceDocument

    @State
    var selectedResult: SearchResultMatchModel?

    @StateObject
    var prefs: AppPreferencesModel = .shared

    typealias NSViewControllerType = FindNavigatorListViewController

    func makeNSViewController(context: Context) -> FindNavigatorListViewController {
        let controller = FindNavigatorListViewController(workspace: workspace)
        controller.setSearchResults(workspace.searchState?.searchResult ?? [])
        controller.rowHeight = prefs.preferences.general.projectNavigatorSize.rowHeight
        context.coordinator.controller = controller
        return controller
    }

    func updateNSViewController(_ nsViewController: FindNavigatorListViewController, context: Context) {
        nsViewController.updateNewSearchResults(workspace.searchState?.searchResult ?? [])
        if nsViewController.rowHeight != prefs.preferences.general.projectNavigatorSize.rowHeight {
            nsViewController.rowHeight = prefs.preferences.general.projectNavigatorSize.rowHeight
        }
        return
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(state: workspace.searchState,
                    controller: nil)
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
                    self?.controller?.updateNewSearchResults(searchResults)
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
