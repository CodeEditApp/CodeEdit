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
        VStack(spacing: 0.0) {
            VStack {
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                        .padding(.leading, 1)
                        .padding(.trailing, 10)
                    TextField("Open Quickly", text: $state.openQuicklyQuery)
                        .font(.system(size: 20, weight: .light, design: .default))
                        .textFieldStyle(.plain)
                        .onReceive(
                            state.$openQuicklyQuery
                                .debounce(for: .seconds(0.4), scheduler: DispatchQueue.main)
                        ) { _ in
                            state.fetchOpenQuickly()
                        }
                }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 12)
                    .foregroundColor(.primary.opacity(0.85))
                    .background(EffectView(.sidebar, blendingMode: .behindWindow))
            }
            if self.state.isShowingOpenQuicklyFiles {
                Divider()
            }
            HStack(spacing: 0) {
                List(state.openQuicklyFiles, id: \.self, selection: $selectedItem) { file in
                    QuickOpenItem(baseDirectory: state.fileURL, fileItem: file)
                }
                .contextMenu(forSelectionType: WorkspaceClient.FileItem.self, menu: { _ in
                    EmptyView()
                }, primaryAction: { files in
                    if let file = files.first {
                        self.openFile(file)
                        self.onClose()
                    }
                })
                .frame(maxWidth: 272)
                Divider()
                if state.openQuicklyFiles.isEmpty {
                    EmptyView()
                        .frame(maxWidth: .infinity)
                } else {
                    if let selectedItem {
                        QuickOpenPreviewView(item: selectedItem)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Select a file to preview")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .background(EffectView(.sidebar, blendingMode: .behindWindow))
        .edgesIgnoringSafeArea(.vertical)
        .frame(
            minWidth: 680,
            minHeight: self.state.isShowingOpenQuicklyFiles ? 400 : 19,
            maxHeight: self.state.isShowingOpenQuicklyFiles ? .infinity : 19
        )
    }
}
