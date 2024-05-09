//
//  WorkspaceCannotPreviewFileView.swift
//  CodeEdit
//
//  Created by Paul Ebose on 2024/5/9.
//

import SwiftUI
import QuickLookThumbnailing

/// This displays a thumbnail for the inputted `fileURL`.
///
/// The thumbnail displayed is a file icon.
/// ```swift
/// WorkspaceCannotPreviewFileView(fileURL)
/// ```
struct WorkspaceCannotPreviewFileView: View {

    /// URL of the file that cannot be previewed.
    private let fileURL: URL

    /// The icon that will be shown instead of the file contents, since the file cannot be previewed.
    @State private var thumbnail: NSImage?

    init(_ fileURL: URL) {
        self.fileURL = fileURL
    }

    /// Generate the file icon that will be used as a thumbnail, and update the `thumbnail` state value.
    private func generateThumbnailRepresentation() {
        // Set up the parameters of the request.
        let size: CGSize = CGSize(width: 256, height: 256)
        let scale = NSScreen.main?.backingScaleFactor ?? 1.0

        // Create the thumbnail request.
        let request = QLThumbnailGenerator.Request(
            fileAt: fileURL,
            size: size,
            scale: scale,
            representationTypes: .icon
        )

        // Retrieve the singleton instance of the thumbnail generator and generate the thumbnails.
        let generator = QLThumbnailGenerator.shared
        generator.generateRepresentations(for: request) { (qlThumbnail, _, _) in
            guard let qlThumbnail else { return }
            thumbnail = qlThumbnail.nsImage
        }
    }

    var body: some View {
        ZStack {
            if let thumbnail {
                Image(nsImage: thumbnail)
            } else {
                WorkspaceLoadingView()
            }
        }
        .onAppear {
            generateThumbnailRepresentation()
        }
    }
}
