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

    @Environment(\.edgeInsets)
    private var edgeInsets

    var codeFile: CodeFileDocument
    var textViewCoordinators: [TextViewCoordinator] = []

    @ViewBuilder var editorAreaFileView: some View {

        if let utType = codeFile.utType, utType.conforms(to: .text) {
            CodeFileView(codeFile: codeFile, textViewCoordinators: textViewCoordinators)
        } else {
            NonTextFileView(fileDocument: codeFile)
                .padding(.top, edgeInsets.top - 1.74) // Use the magic number to fine-tune its appearance.
                .padding(.bottom, StatusBarView.height + 1.26) // Use the magic number to fine-tune its appearance.
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
