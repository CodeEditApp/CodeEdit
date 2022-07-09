//
//  SearchResultList.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/22.
//

import SwiftUI
import WorkspaceClient
import Search

struct FindNavigatorResultList: NSViewControllerRepresentable {

    @ObservedObject
    private var state: WorkspaceDocument.SearchState

    @State
    private var selectedResult: SearchResultMatchModel?

    typealias NSViewControllerType = FindNavigatorListViewController

    init(state: WorkspaceDocument.SearchState, selectedResult: SearchResultMatchModel? = nil) {
        self.state = state
        self.selectedResult = selectedResult
    }

    func makeNSViewController(context: Context) -> FindNavigatorListViewController {
        let controller = FindNavigatorListViewController()
        controller.searchItems = state.searchResult
        context.coordinator.controller = controller
        return controller
    }

    func updateNSViewController(_ nsViewController: FindNavigatorListViewController, context: Context) {
        nsViewController.searchItems = state.searchResult
        nsViewController.outlineView.reloadData()
        return
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject {
        var controller: FindNavigatorListViewController?

        deinit {
            controller = nil
        }
    }

//    private func getResultWith(_ file: WorkspaceClient.FileItem) -> [SearchResultModel] {
//        state.searchResult.filter { $0.file == file }
//    }
//
//    var body: some View {
//        List(selection: $selectedResult) {
//
//        }
//        .listStyle(.sidebar)
//        .onChange(of: selectedResult) { newValue in
//            if let file = newValue?.file {
//                state.workspace.openTab(item: file)
//            }
//        }
//    }
}
