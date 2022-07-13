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

    @ObservedObject
    private var state: WorkspaceDocument.SearchState

    @State
    private var selectedResult: SearchResultMatchModel?

    @StateObject
    var prefs: AppPreferencesModel = .shared

    typealias NSViewControllerType = FindNavigatorListViewController

    init(state: WorkspaceDocument.SearchState, selectedResult: SearchResultMatchModel? = nil) {
        self.state = state
        self.selectedResult = selectedResult
    }

    func makeNSViewController(context: Context) -> FindNavigatorListViewController {
        let controller = FindNavigatorListViewController()
        controller.searchItems = state.searchResult
        controller.rowHeight = prefs.preferences.general.projectNavigatorSize.rowHeight
        context.coordinator.controller = controller
        return controller
    }

    func updateNSViewController(_ nsViewController: FindNavigatorListViewController, context: Context) {
        nsViewController.updateNewSearchResults(state.searchResult)
        if nsViewController.rowHeight != prefs.preferences.general.projectNavigatorSize.rowHeight {
            nsViewController.rowHeight = prefs.preferences.general.projectNavigatorSize.rowHeight
        }
        return
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(state: state,
                    controller: nil)
    }

    class Coordinator: NSObject {
        init(state: WorkspaceDocument.SearchState, controller: FindNavigatorListViewController?) {
            self.controller = controller
            super.init()
            self.listener = state.searchResult
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
