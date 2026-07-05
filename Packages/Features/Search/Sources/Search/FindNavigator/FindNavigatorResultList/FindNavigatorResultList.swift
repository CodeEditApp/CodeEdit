//
//  SearchResultList.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/22.
//

import SwiftUI
import Combine

struct FindNavigatorResultList: NSViewControllerRepresentable {

    @EnvironmentObject var state: SearchState

    let configuration: FindNavigatorConfiguration

    typealias NSViewControllerType = FindNavigatorListViewController

    func makeNSViewController(context: Context) -> FindNavigatorListViewController {
        let controller = FindNavigatorListViewController(configuration: configuration)
        controller.setSearchResults(state.searchResult)
        controller.rowHeight = configuration.rowHeight
        context.coordinator.controller = controller
        return controller
    }

    func updateNSViewController(_ nsViewController: FindNavigatorListViewController, context: Context) {
        nsViewController.updateNewSearchResults(state.searchResult)
        if nsViewController.configuration != configuration {
            nsViewController.configuration = configuration
            nsViewController.rowHeight = configuration.rowHeight
        }
        return
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            state: state,
            controller: nil
        )
    }

    @MainActor
    class Coordinator: NSObject {
        init(state: SearchState?, controller: FindNavigatorListViewController?) {
            self.controller = controller
            super.init()
            self.listener = state?
                .$searchResult
                .sink(receiveValue: { [weak self] searchResults in
                    // `searchResult` is only mutated on the main actor (`setSearchResults`
                    // is @MainActor; `clearResults` hops to main), so delivery is main-thread.
                    MainActor.assumeIsolated {
                        self?.controller?.updateNewSearchResults(searchResults)
                    }
                })
        }

        var listener: AnyCancellable?
        var controller: FindNavigatorListViewController?

        // No explicit deinit: `AnyCancellable` cancels its subscription automatically
        // on deallocation, and a nonisolated deinit may not touch main-actor state.
    }
}
