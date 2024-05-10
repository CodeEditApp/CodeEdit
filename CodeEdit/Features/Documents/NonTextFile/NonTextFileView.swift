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

    var body: some View {

        if let fileURL = fileDocument.fileURL {

            switch fileDocument.utType {
            case .some(.gif):
                // GIF conforms to image, so to differentiate, the GIF check has to come before the image check.
                WorkspaceImageView(fileURL, isGif: true)

            case .some(.image):
                WorkspaceImageView(fileURL)

            case .some(.pdf):
                WorkspacePDFView(fileURL)

            default:
                WorkspaceAnyFileView(fileURL)
            }

        } else {
            ZStack {
                Text("Cannot retrieve URL to the file you opened.")
            }
        }

    }
}
