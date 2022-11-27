//
//  BreadcrumbsView.swift
//  CodeEditModules/Breadcrumbs
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct BreadcrumbsView: View {

    private let file: WorkspaceClient.FileItem
    private let tappedOpenFile: (WorkspaceClient.FileItem) -> Void

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.controlActiveState)
    private var activeState

    @State
    private var fileItems: [WorkspaceClient.FileItem] = []

    init(
        file: WorkspaceClient.FileItem,
        tappedOpenFile: @escaping (WorkspaceClient.FileItem) -> Void
    ) {
        self.file = file
        self.tappedOpenFile = tappedOpenFile
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 1.5) {
                ForEach(fileItems, id: \.self) { fileItem in
                    if fileItem.parent != nil {
                        chevron
                    }
                    BreadcrumbsComponent(fileItem: fileItem, tappedOpenFile: tappedOpenFile)
                        .padding(.leading, 2.5)
                }
            }
            .padding(.horizontal, 10)
        }
        .frame(height: 28, alignment: .center)
        .onAppear {
            fileInfo(self.file)
        }
        .onChange(of: file) { newFile in
            fileInfo(newFile)
        }
    }

    private var chevron: some View {
        Image(systemName: "chevron.compact.right")
            .font(.system(size: 14, weight: .thin, design: .default))
            .foregroundStyle(.primary)
            .scaleEffect(x: 1.30, y: 1.0, anchor: .center)
            .imageScale(.large)
            .opacity(activeState != .inactive ? 0.8 : 0.5)
    }

    private func fileInfo(_ file: WorkspaceClient.FileItem) {
        fileItems = []
        var currentFile: WorkspaceClient.FileItem? = file
        while let currentFileLoop = currentFile {
            fileItems.insert(currentFileLoop, at: 0)
            currentFile = currentFileLoop.parent
        }
    }
}

struct BreadcrumbsView_Previews: PreviewProvider {
    static var previews: some View {
        BreadcrumbsView(file: .init(url: .init(fileURLWithPath: ""))) { _ in }
            .previewLayout(.fixed(width: 500, height: 29))
            .preferredColorScheme(.dark)

        BreadcrumbsView(file: .init(url: .init(fileURLWithPath: ""))) { _ in }
            .previewLayout(.fixed(width: 500, height: 29))
            .preferredColorScheme(.light)
    }
}
