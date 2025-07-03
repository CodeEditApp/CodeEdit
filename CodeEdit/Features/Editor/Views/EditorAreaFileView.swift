//
//  EditorAreaFileView.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 20.03.22.
//

import AppKit
import AVKit
import CodeEditSourceEditor
import SwiftUI

struct EditorAreaFileView: View {

    @EnvironmentObject private var editorManager: EditorManager
    @EnvironmentObject private var editor: Editor
    @EnvironmentObject private var statusBarViewModel: StatusBarViewModel

    @Environment(\.edgeInsets)
    private var edgeInsets

    var editorInstance: EditorInstance
    var codeFile: CodeFileDocument

    @ViewBuilder var editorAreaFileView: some View {
        if let utType = codeFile.utType, utType.conforms(to: .text) {
            CodeFileView(
                editorInstance: editorInstance,
                codeFile: codeFile
            )
        } else {
            NonTextFileView(fileDocument: codeFile)
                .padding(.top, edgeInsets.top - 1.74)
                .padding(.bottom, StatusBarView.height + 1.26)
                .modifier(UpdateStatusBarInfo(with: codeFile.fileURL))
                .onDisappear {
                    statusBarViewModel.dimensions = nil
                    statusBarViewModel.fileSize = nil
                }
        }
    }

    var body: some View {
        editorAreaFileView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onHover { hover in
                DispatchQueue.main.async {
                    if hover {
                        NSCursor.iBeam.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            }
    }
}
