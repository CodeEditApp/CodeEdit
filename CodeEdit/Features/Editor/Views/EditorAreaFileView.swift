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

    var codeFile: CodeFileDocument
    var textViewCoordinators: [TextViewCoordinator] = []

    @ViewBuilder var editorAreaFileView: some View {
        if let document = file.fileDocument {
            if file.isOpeningInQuickLook {
                AnyFileView(file.url)
                    .padding(.top, edgeInsets.top - 1.74)
                    .padding(.bottom, StatusBarView.height + 1.26)
            } else if let utType = document.utType, utType.conforms(to: .text) {
                CodeFileView(codeFile: document, textViewCoordinators: textViewCoordinators)
            } else {
                NonTextFileView(fileDocument: document)
                    .padding(.top, edgeInsets.top - 1.74)
                    .padding(.bottom, StatusBarView.height + 1.26)
                    .modifier(UpdateStatusBarInfo(with: document.fileURL))
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
