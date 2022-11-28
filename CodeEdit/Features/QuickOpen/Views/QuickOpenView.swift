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
                    Image(systemName: "doc.text.magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 12)
                        .offset(x: 0, y: 1)
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
                    .padding(16)
                    .foregroundColor(.primary.opacity(0.85))
                    .background(EffectView(.sidebar, blendingMode: .behindWindow))
            }
            Divider()
            NavigationView {
                List(state.openQuicklyFiles, id: \.id) { file in
                    NavigationLink(tag: file, selection: $selectedItem) {
                        QuickOpenPreviewView(item: file)
                    } label: {
                        QuickOpenItem(baseDirectory: state.fileURL, fileItem: file)
                    }
                    .onTapGesture(count: 2) {
                        self.openFile(file)
                        self.onClose()
                    }
                    .onTapGesture(count: 1) {
                        self.selectedItem = file
                    }
                }
                .frame(minWidth: 250, maxWidth: 250)
                if state.openQuicklyFiles.isEmpty {
                    EmptyView()
                } else {
                    Text("Select a file to preview")
                }
            }
        }
            .background(EffectView(.sidebar, blendingMode: .behindWindow))
            .edgesIgnoringSafeArea(.vertical)
            .frame(minWidth: 600,
               minHeight: self.state.isShowingOpenQuicklyFiles ? 400 : 28,
               maxHeight: self.state.isShowingOpenQuicklyFiles ? .infinity : 28)
    }
}

struct QuickOpenView_Previews: PreviewProvider {
    static var previews: some View {
        QuickOpenView(
            state: .init(fileURL: .init(fileURLWithPath: "")),
            onClose: {},
            openFile: { _ in }
        )
    }
}
