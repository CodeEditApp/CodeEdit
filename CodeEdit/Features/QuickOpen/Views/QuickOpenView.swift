//
//  QuickOpenView.swift
//  CodeEditModules/QuickOpen
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI

extension URL: Identifiable {
    public var id: String {
        absoluteString
    }
}

struct QuickOpenView: View {
    @EnvironmentObject private var workspace: WorkspaceDocument

    private let onClose: () -> Void
    private let openFile: (CEWorkspaceFile) -> Void

    @ObservedObject private var state: QuickOpenViewModel

    @State private var selectedItem: CEWorkspaceFile?

    init(
        state: QuickOpenViewModel,
        onClose: @escaping () -> Void,
        openFile: @escaping (CEWorkspaceFile) -> Void
    ) {
        self.state = state
        self.onClose = onClose
        self.openFile = openFile
    }

    var body: some View {
        SearchPanelView(
            title: "Open Quickly",
            image: Image(systemName: "magnifyingglass"),
            options: $state.openQuicklyFiles,
            text: $state.openQuicklyQuery,
            optionRowHeight: 40
        ) { file in
            QuickOpenItem(baseDirectory: state.fileURL, fileURL: file)
        } preview: { fileURL in
            QuickOpenPreviewView(item: CEWorkspaceFile(url: fileURL))
        } onRowClick: { fileURL in
            guard let file = workspace.workspaceFileManager?.getFile(
                fileURL.relativePath,
                createIfNotFound: true
            ) else {
                return
            }
            openFile(file)
            state.openQuicklyQuery = ""
            onClose()
        } onClose: {
            onClose()
        }
        .onReceive(state.$openQuicklyQuery.debounce(for: 0.2, scheduler: DispatchQueue.main)) { _ in
            state.fetchOpenQuickly()
        }
    }
}
