//
//  OpenQuicklyView.swift
//  CodeEditModules/QuickOpen
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI

struct OpenQuicklyOverlayView: View {

    private let onClose: () -> Void
    private let openFile: (CEWorkspaceFile) -> Void

    @ObservedObject
    private var state: QuickOpenViewModel

    @State
    private var selectedItem: CEWorkspaceFile?

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
        OverlayView(
            title: "Open Quickly",
            image: Image(systemName: "magnifyingglass"),
            options: $state.openQuicklyFiles,
            text: $state.openQuicklyQuery,
            optionRowHeight: 40
        ) { file, _  in
            OpenQuicklyOverlayItem(baseDirectory: state.fileURL, fileItem: file)
        } preview: { file in
            OpenQuicklyOverlayPreviewView(item: file)
        } onRowClick: { file in
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
