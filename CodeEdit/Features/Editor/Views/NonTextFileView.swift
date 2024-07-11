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

    var body: some View {

        Group {
            if let fileURL = fileDocument.fileURL {
                if let utType = fileDocument.utType {
                    if utType.conforms(to: .image) {
                        ImageFileView(fileURL)
                            .modifier(UpdateStatusBarInfo(withURL: fileURL))
                    } else if utType.conforms(to: .pdf) {
                        PDFFileView(fileURL)
                            .modifier(UpdateStatusBarInfo(withURL: fileURL))
                    } else {
                        QuickLookFileView(fileURL)
                            .modifier(UpdateStatusBarInfo(withURL: fileURL))
                    }
                } else {
                    QuickLookFileView(fileURL)
                        .modifier(UpdateStatusBarInfo(withURL: fileURL))
                }
            } else {
                ZStack {
                    Text("Cannot retrieve URL to the file you opened.")
                }
            }
        }
        .onDisappear {
            statusBarViewModel.dimensions = nil
            statusBarViewModel.fileSize = nil
        }
    }
}
