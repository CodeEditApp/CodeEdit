//
//  QuickOpenView.swift
//  CodeEditModules/QuickOpen
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI

struct QuickOpenView: View {

    private let onClose: () -> Void
    private let openFile: (WorkspaceClient.FileItem) -> Void

    @ObservedObject
    private var state: QuickOpenViewModel

    @State
    private var selectedItem: WorkspaceClient.FileItem?

    init(
        state: QuickOpenViewModel,
        onClose: @escaping () -> Void,
        openFile: @escaping (WorkspaceClient.FileItem) -> Void
    ) {
        self.state = state
        self.onClose = onClose
        self.openFile = openFile
    }

    var body: some View {
        OverlayView(
            title: "Open Quickly",
            image: Image(systemName: "magnifyingglass"),
            options: $state.openQuicklyFiles,
            text: $state.openQuicklyQuery,
            optionRowHeight: 40
        ) { file in
            QuickOpenItem(baseDirectory: state.fileURL, fileItem: file)
        } preview: { file in
            QuickOpenPreviewView(item: file)
        } onRowClick: { file in
            openFile(file)
            onClose()
        } onClose: {
            onClose()
        }
        .onReceive(state.$openQuicklyQuery.debounce(for: 0.2, scheduler: DispatchQueue.main)) { _ in
            state.fetchOpenQuickly()
        }
    }
}
