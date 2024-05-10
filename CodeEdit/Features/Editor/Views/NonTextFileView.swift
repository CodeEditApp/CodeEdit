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
            case .some(.image):
                ImageFileView(fileURL)

            case .some(.pdf):
                PDFFileView(fileURL)

            default:
                AnyFileView(fileURL)
            }

        } else {
            ZStack {
                Text("Cannot retrieve URL to the file you opened.")
            }
        }

    }
}
