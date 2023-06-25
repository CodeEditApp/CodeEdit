//
//  QuickOpenView.swift
//  CodeEditModules/QuickOpen
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI

struct QuickOpenView: View {

    typealias Item = QuickOpenViewModel.Item

    private let onClose: () -> Void
    private let openFile: (File) -> Void

    @ObservedObject private var state: QuickOpenViewModel

    @State private var selectedItem: Item?

    init(
        state: QuickOpenViewModel,
        onClose: @escaping () -> Void,
        openFile: @escaping (File) -> Void
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
            QuickOpenItem(fileItem: file)
        } preview: { file in
            let result = Result {
                try QuickOpenPreviewView(item: file)
            }

            switch result {
            case .success(let success):
                success
            case .failure(let failure):
                Text("There was an error opening the file: \(failure.localizedDescription)")
            }

        } onRowClick: { file in
            openFile(file)
            state.openQuicklyQuery = ""
            onClose()
        } onClose: {
            onClose()
        }
        .task(id: state.openQuicklyQuery) {
            try? await Task.sleep(for: .milliseconds(200))
            await state.fetchOpenQuickly()
        }
    }
}
