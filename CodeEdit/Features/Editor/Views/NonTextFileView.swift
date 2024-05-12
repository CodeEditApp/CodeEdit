//
//  NonTextFileView.swift
//  CodeEdit
//
//  Created by Paul Ebose on 2024/5/10.
//

import SwiftUI

/// Determines what type of file is passed in, and previews it accordingly.
///
/// ```swift
/// NonTextFileView(fileDocument)
/// ```
struct NonTextFileView: View {

    /// The file document you wish to open.
    let fileDocument: CodeFileDocument

    @EnvironmentObject private var editorManager: EditorManager
    @EnvironmentObject private var statusBarViewModel: StatusBarViewModel

    private func updateStatusBarInfo(fileURL: URL, dimensions: (Int, Int)? = nil) {
        statusBarViewModel.dimensions = dimensions
        if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
            statusBarViewModel.fileSize = fileSize
        }
    }

    var body: some View {

        if let fileURL = fileDocument.fileURL {

            switch fileDocument.utType {
            case .some(.image):
                ImageFileView(fileURL)

            case .some(.pdf):
                PDFFileView(fileURL)
                    .onAppear { updateStatusBarInfo(fileURL: fileURL) }
                    .onChange(of: editorManager.activeEditor.selectedTab) { newTab in
                        if let newTab { updateStatusBarInfo(fileURL: newTab.file.url) }
                    }

            default:
                AnyFileView(fileURL)
                    .onAppear { updateStatusBarInfo(fileURL: fileURL) }
                    .onChange(of: editorManager.activeEditor.selectedTab) { newTab in
                        if let newTab { updateStatusBarInfo(fileURL: newTab.file.url) }
                    }
            }

        } else {
            ZStack {
                Text("Cannot retrieve URL to the file you opened.")
            }
        }

    }
}
