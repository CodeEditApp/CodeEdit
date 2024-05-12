//
//  ImageFileView.swift
//  CodeEdit
//
//  Created by Paul Ebose on 2024/5/9.
//

import SwiftUI

/// A view for previewing an image, while respecting its dimensions.
///
/// It receives a URL to an image file and attempts to preview it.
///
/// ```swift
/// ImageFileView(imageURL)
/// ```
/// This implementation allows for proper image scaling, especially when the image dimensions are smaller than
/// the size of the image view area.
///
/// If the preview image cannot be created, it shows a  *"Cannot preview image"* text.
struct ImageFileView: View {

    /// URL of the image you want to preview.
    private let imageURL: URL

    init(_ imageURL: URL) {
        self.imageURL = imageURL
    }

    @EnvironmentObject private var editorManager: EditorManager
    @EnvironmentObject private var statusBarViewModel: StatusBarViewModel

    private func updateStatusBarInfo(fileURL: URL, dimensions: (Int, Int)? = nil) {
        statusBarViewModel.dimensions = dimensions
        if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
            statusBarViewModel.fileSize = fileSize
        }
    }

    var body: some View {
        if let nsImage = NSImage(contentsOf: imageURL),
           let imageReps = nsImage.representations.first {

            let pixelWidth = CGFloat(imageReps.pixelsWide)
            let pixelHeight = CGFloat(imageReps.pixelsHigh)

            GeometryReader { proxy in
                ZStack {
                    AnyFileView(imageURL)
                        .frame(
                            maxWidth: min(pixelWidth, proxy.size.width, nsImage.size.width),
                            maxHeight: min(pixelHeight, proxy.size.height, nsImage.size.height)
                        )
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .onAppear {
                    updateStatusBarInfo(
                        fileURL: imageURL,
                        dimensions: (imageReps.pixelsWide, imageReps.pixelsHigh)
                    )
                }
                .onChange(of: editorManager.activeEditor.selectedTab) { newTab in
                    if let newTab {
                        updateStatusBarInfo(
                            fileURL: newTab.file.url,
                            dimensions: (imageReps.pixelsWide, imageReps.pixelsHigh)
                        )
                    }
                }
            }
        } else {
            Text("Cannot preview image")
        }
    }

}
