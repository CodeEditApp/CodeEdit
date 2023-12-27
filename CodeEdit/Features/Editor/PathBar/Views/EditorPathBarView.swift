//
//  EditorPathBarView.swift
//  CodeEditModules/PathBar
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct EditorPathBarView: View {
    private let file: CEWorkspaceFile?
    private let tappedOpenFile: (CEWorkspaceFile) -> Void

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.isActiveEditor)
    private var isActiveEditor

    @Environment(\.controlActiveState)
    private var activeState

    static let height = 27.0

    init(
        file: CEWorkspaceFile?,
        tappedOpenFile: @escaping (CEWorkspaceFile) -> Void
    ) {
        self.file = file ?? nil
        self.tappedOpenFile = tappedOpenFile
    }

    var fileItems: [CEWorkspaceFile] {
        var treePath: [CEWorkspaceFile] = []
        var currentFile: CEWorkspaceFile? = file

        while let currentFileLoop = currentFile {
            treePath.insert(currentFileLoop, at: 0)
            currentFile = currentFileLoop.parent
        }

        return treePath
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                if file == nil {
                    Text("No Selection")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(
                            activeState != .inactive
                            ? isActiveEditor ? .primary : .secondary
                            : Color(nsColor: .tertiaryLabelColor)
                        )
                } else {
                    ForEach(fileItems, id: \.self) { fileItem in
                        EditorPathBarComponent(
                            fileItem: fileItem,
                            tappedOpenFile: tappedOpenFile,
                            isLastItem: fileItems.last == fileItem
                        )
                    }
                }
            }
            .padding(.horizontal, 10)
        }
        .frame(height: Self.height, alignment: .center)
        .opacity(activeState == .inactive ? 0.8 : 1.0)
        .grayscale(isActiveEditor ? 0.0 : 1.0)
    }
}
