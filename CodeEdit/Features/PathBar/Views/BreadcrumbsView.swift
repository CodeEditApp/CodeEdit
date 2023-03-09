//
//  PathBarView.swift
//  CodeEditModules/PathBar
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct PathBarView: View {

    private let file: WorkspaceClient.FileItem
    private let tappedOpenFile: (WorkspaceClient.FileItem) -> Void

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.isActiveTabGroup)
    private var isActiveTabGroup

    @Environment(\.controlActiveState)
    private var activeState

    static let height = 27.0

    init(
        file: WorkspaceClient.FileItem,
        tappedOpenFile: @escaping (WorkspaceClient.FileItem) -> Void
    ) {
        self.file = file
        self.tappedOpenFile = tappedOpenFile
    }

    var fileItems: [WorkspaceClient.FileItem] {
        var treePath: [WorkspaceClient.FileItem] = []
        var currentFile: WorkspaceClient.FileItem? = file

        while let currentFileLoop = currentFile {
            treePath.insert(currentFileLoop, at: 0)
            currentFile = currentFileLoop.parent
        }

        return treePath
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 1.5) {
                ForEach(fileItems, id: \.self) { fileItem in
                    if fileItem.parent != nil {
                        chevron
                    }
                    PathBarComponent(fileItem: fileItem, tappedOpenFile: tappedOpenFile)
                        .padding(.leading, 2.5)
                }
            }
            .padding(.horizontal, 10)
        }
        .frame(height: Self.height, alignment: .center)
        .opacity(activeState == .inactive ? 0.8 : 1.0)
        .grayscale(isActiveTabGroup ? 0.0 : 1.0)
        .background(EffectView(.headerView).frame(height: Self.height))
    }

    private var chevron: some View {
        Image(systemName: "chevron.compact.right")
            .font(.system(size: 14, weight: .thin, design: .default))
            .foregroundStyle(.primary)
            .scaleEffect(x: 1.30, y: 1.0, anchor: .center)
            .imageScale(.large)
            .opacity(activeState != .inactive ? 0.8 : 0.5)
    }
}
