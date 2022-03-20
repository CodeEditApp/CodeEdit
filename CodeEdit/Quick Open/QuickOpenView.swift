//
//  QuickOpenView.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI

struct QuickOpenView: View {
    @ObservedObject var workspace: WorkspaceDocument
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 0.0) {
            VStack {
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .imageScale(.large)
                        .padding(.horizontal)
                    TextField("Open Quickly", text: $workspace.openQuicklyQuery)
                        .font(.system(size: 22, weight: .light, design: .default))
                        .textFieldStyle(.plain)
                        .onReceive(
                            workspace.$openQuicklyQuery
                                .debounce(for: .seconds(0.4), scheduler: DispatchQueue.main)
                        ) { _ in
                            workspace.fetchOpenQuickly()
                        }
                }
                    .frame(height: 28)
                    .padding(.vertical)
                    .foregroundColor(.primary.opacity(0.85))
                    .background(BlurView(material: .sidebar, blendingMode: .behindWindow))
            }
            Divider()
            NavigationView {
                List(workspace.openQuicklyFiles, id: \.id) { file in
                    NavigationLink {
                        Text(file.url.lastPathComponent)
                    } label: {
                        QuickOpenItem(fileItem: file)
                    }
                    .onTapGesture(count: 2) {
                        workspace.openFile(item: file)
                        self.onClose()
                    }
                }
                    .removeBackground()
                    .frame(minWidth: 250, maxWidth: 250)
                if workspace.openQuicklyFiles.isEmpty {
                    EmptyView()
                } else {
                    Text("Select a file to preview")
                }
            }
        }
            .background(BlurView(material: .sidebar, blendingMode: .behindWindow))
            .edgesIgnoringSafeArea(.vertical)
            .frame(minWidth: 600,
               minHeight: 400,
               maxHeight: .infinity)
    }
}

struct QuickOpenView_Previews: PreviewProvider {
    static var previews: some View {
        QuickOpenView(workspace: .init(), onClose: {})
    }
}
