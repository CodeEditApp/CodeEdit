//
//  WorkspaceCodeFileView.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 20.03.22.
//

import AppKit
import AVKit
import CodeEditSourceEditor
import SwiftUI

struct WorkspaceCodeFileView: View {

    @EnvironmentObject private var editorManager: EditorManager

    @EnvironmentObject private var editor: Editor

    @Environment(\.edgeInsets)
    private var edgeInsets

    var file: CEWorkspaceFile
    var textViewCoordinators: [TextViewCoordinator] = []

    @State private var update: Bool = false

    @ViewBuilder var codeView: some View {
        if let document = file.fileDocument,
           let documentURL = document.fileURL {

            // `document.utType` should remain an Optional, or else, it skips this 'if' block.
            // We should still display WorkspaceAnyFileView when there is a 'nil' utType.

            switch document.utType {
            case .some(.text):
                CodeFileView(codeFile: document, textViewCoordinators: textViewCoordinators)

            // Group non-text files, so they inherit modifiers from the parent Group view.
            default:
                Group {
                    switch document.utType {
                    case .some(.gif):
                        // GIF conforms to image, so to differentiate, the GIF check has to come before the image check
                        WorkspaceImageView(documentURL, isGif: true)

                    case .some(.image):
                        WorkspaceImageView(documentURL)

                    case .some(.pdf):
                        WorkspacePDFView(documentURL)

                    default:
                        WorkspaceAnyFileView(documentURL)
                    }
                }
                .padding(.top, edgeInsets.top - 1.74) // Use the magic number to fine-tune its appearance.
                .padding(.bottom, StatusBarView.height + 1.26) // Use the magic number to fine-tune its appearance.
        }
        } else {
            if update {
                Spacer()
            }
            Spacer()
            WorkspaceLoadingView(file.name)
            Spacer()
                .onAppear {
                    Task.detached {
                        let contentType = try await file.url.resourceValues(forKeys: [.contentTypeKey]).contentType
                        let codeFile = try await CodeFileDocument(
                            for: file.url,
                            withContentsOf: file.url,
                            ofType: contentType?.identifier ?? ""
                        )
                        await MainActor.run {
                            file.fileDocument = codeFile
                            CodeEditDocumentController.shared.addDocument(codeFile)
                            update.toggle()
                        }
                    }
                }
        }
    }

    @ViewBuilder
    private func otherFileView(
        _ otherFile: CodeFileDocument,
        for item: CEWorkspaceFile
    ) -> some View {
        VStack(spacing: 0) {
            if let url = otherFile.previewItemURL,
               let image = NSImage(contentsOf: url),
               otherFile.utType == .image {
                GeometryReader { proxy in
                    if image.size.width > proxy.size.width || image.size.height > proxy.size.height {
                        OtherFileView(otherFile)
                    } else {
                        OtherFileView(otherFile)
                            .frame(
                                width: proxy.size.width * (proxy.size.width / image.size.width),
                                height: proxy.size.height
                            )
                            .position(x: proxy.frame(in: .local).midX, y: proxy.frame(in: .local).midY)
                    }
                }
            } else {
                OtherFileView(otherFile)
            }
        }
    }

    var body: some View {
        codeView
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
