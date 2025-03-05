//
//  OpenQuicklyView.swift
//  CodeEditModules/QuickOpen
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI

struct OpenQuicklyView: View {
    @EnvironmentObject private var workspace: WorkspaceDocument

    private let onClose: () -> Void
    private let openFile: (CEWorkspaceFile) -> Void

    @ObservedObject private var openQuicklyViewModel: OpenQuicklyViewModel

    @State private var selectedItem: CEWorkspaceFile?

    init(
        state: OpenQuicklyViewModel,
        onClose: @escaping () -> Void,
        openFile: @escaping (CEWorkspaceFile) -> Void
    ) {
        self.openQuicklyViewModel = state
        self.onClose = onClose
        self.openFile = openFile
    }

    var body: some View {
        SearchPanelView(
            title: "Open Quickly",
            image: Image(systemName: "magnifyingglass"),
            options: $openQuicklyViewModel.searchResults,
            text: $openQuicklyViewModel.query,
            optionRowHeight: 40
        ) { searchResult in
            OpenQuicklyListItemView(
                baseDirectory: openQuicklyViewModel.fileURL,
                searchResult: searchResult
            )
        } preview: { searchResult in
            OpenQuicklyPreviewView(item: CEWorkspaceFile(url: searchResult.fileURL))
        } onRowClick: { searchResult in
            guard let file = workspace.workspaceFileManager?.getFile(
                searchResult.fileURL.relativePath,
                createIfNotFound: true
            ) else {
                return
            }
            openFile(file)
            openQuicklyViewModel.query = ""
            onClose()
        } onClose: {
            onClose()
        }
        .onReceive(openQuicklyViewModel.$query.debounce(for: 0.2, scheduler: DispatchQueue.main)) { _ in
            openQuicklyViewModel.fetchResults()
        }
    }
}
