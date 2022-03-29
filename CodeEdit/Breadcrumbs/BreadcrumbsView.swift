//
//  BreadcrumbsView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import WorkspaceClient

struct BreadcrumbsView: View {
    @Environment(\.colorScheme)
    private var colorScheme

    @ObservedObject
    var workspace: WorkspaceDocument

    let file: WorkspaceClient.FileItem

    @State
    private var fileItems: [WorkspaceClient.FileItem] = []

    init(_ file: WorkspaceClient.FileItem, workspace: WorkspaceDocument) {
        self.file = file
        self.workspace = workspace
    }

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .foregroundStyle(Color(nsColor: .controlBackgroundColor))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(fileItems, id: \.self) { fileItem in
                        if fileItem.parent != nil {
                            chevron
                        }
                        BreadcrumbsComponent(workspace, fileItem: fileItem)
                    }
                }
                .padding(.horizontal, 12)
            }
        }
        .frame(height: 29)
        .overlay(alignment: .bottom) {
            Divider()
        }
        .onAppear {
            fileInfo(self.file)
        }
        .onChange(of: file) { newFile in
            fileInfo(newFile)
        }
    }

    private var chevron: some View {
        Image(systemName: "chevron.compact.right")
            .foregroundStyle(.secondary)
            .imageScale(.large)
    }

    private func fileInfo(_ file: WorkspaceClient.FileItem) {
        self.fileItems = []
        var currentFile: WorkspaceClient.FileItem? = file
        while let currentFileLoop = currentFile {
            self.fileItems.insert(currentFileLoop, at: 0)
            currentFile = currentFileLoop.parent
        }
    }
}

struct BreadcrumbsView_Previews: PreviewProvider {
    static var previews: some View {
        BreadcrumbsView(.init(url: .init(fileURLWithPath: "", isDirectory: false)), workspace: .init())
            .previewLayout(.fixed(width: 500, height: 29))
            .preferredColorScheme(.dark)

        BreadcrumbsView(.init(url: .init(fileURLWithPath: "", isDirectory: false)), workspace: .init())
            .previewLayout(.fixed(width: 500, height: 29))
            .preferredColorScheme(.light)
    }
}
