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
    @StateObject private var previewRunner = SwiftUIPreviewRunner()
    @State private var hasSwiftUIPreview = false

    @ViewBuilder var editorAreaFileView: some View {
        if let utType = codeFile.utType, utType.conforms(to: .text) {
            if hasSwiftUIPreview {
                HSplitView {
                    CodeFileView(
                        editorInstance: editorInstance,
                        codeFile: codeFile
                    )

                    SwiftUIPreviewCanvasView(runner: previewRunner)
                }
            } else {
                CodeFileView(
                    editorInstance: editorInstance,
                    codeFile: codeFile
                )
            }
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
            .onAppear {
                updateSwiftUIPreview()
            }
            .onChange(of: codeFile.fileURL) { _, _ in
                updateSwiftUIPreview()
            }
            .onReceive(codeFile.contentCoordinator.textUpdatePublisher) { _ in
                updateSwiftUIPreview()
            }
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

    private func updateSwiftUIPreview() {
        guard codeFile.fileURL?.pathExtension.lowercased() == "swift",
              let source = codeFile.content?.string,
              SwiftUIPreviewParser.firstPreview(in: source) != nil else {
            hasSwiftUIPreview = false
            previewRunner.clear()
            return
        }

        hasSwiftUIPreview = true
        previewRunner.compile(source: source, fileURL: codeFile.fileURL)
    }
}
