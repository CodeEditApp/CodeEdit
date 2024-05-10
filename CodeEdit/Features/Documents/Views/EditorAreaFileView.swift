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

    var file: CEWorkspaceFile
    var textViewCoordinators: [TextViewCoordinator] = []

    @State private var update: Bool = false

    @ViewBuilder var editorAreaFileView: some View {
        if let document = file.fileDocument {

            if let utType = document.utType, utType.conforms(to: .text) {
                CodeFileView(codeFile: document, textViewCoordinators: textViewCoordinators)
            } else {
                NonTextFileView(fileDocument: document)
                    .padding(.top, edgeInsets.top - 1.74) // Use the magic number to fine-tune its appearance.
                    .padding(.bottom, StatusBarView.height + 1.26) // Use the magic number to fine-tune its appearance.
            }

        } else {
            if update {
                Spacer()
            }
            Spacer()
            LoadingFileView(file.name)
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
