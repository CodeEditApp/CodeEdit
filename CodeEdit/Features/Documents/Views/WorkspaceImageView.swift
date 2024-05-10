//
//  WorkspaceImageView.swift
//  CodeEdit
//
//  Created by Paul Ebose on 2024/5/9.
//

import SwiftUI

/// A view for previewing an image, while respecting its image dimensions.
///
/// It receives a URL to an image file and attempts to preview it.
///
/// ```swift
/// WorkspaceImageView(imageURL)
/// ```
/// This implementation allows for proper image scaling, especially when the image dimensions is smaller than
/// the size of the image view area.
///
/// If the preview image cannot be created, it shows a  *"Cannot preview image"* text.
///
/// - Note: This view wraps around SwiftUI Image. Since SwiftUI Image view do not play GIFs, you should indicate
/// when passing in a GIF file, so this view can handle the GIF file correctly.
struct WorkspaceImageView: View {

    /// URL of the image you want to preview.
    private let imageURL: URL

    /// Indicates whether the image is a GIF.
    private let isGif: Bool

    init(_ imageURL: URL, isGif: Bool = false) {
        self.imageURL = imageURL
        self.isGif = isGif
    }

    var body: some View {
        if let nsImage = NSImage(contentsOf: imageURL),
           let imageReps = nsImage.representations.first {

            let pixelWidth = CGFloat(imageReps.pixelsWide)
            let pixelHeight = CGFloat(imageReps.pixelsHigh)

            GeometryReader { proxy in
                ZStack {
                    if isGif {
                        WorkspaceAnyFileView(imageURL)
                            .frame(
                                maxWidth: min(pixelWidth, proxy.size.width, nsImage.size.width),
                                maxHeight: min(pixelHeight, proxy.size.height, nsImage.size.height)
                            )
                    } else {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFit()
                            .frame(
                                maxWidth: min(pixelWidth, proxy.size.width, nsImage.size.width),
                                maxHeight: min(pixelHeight, proxy.size.height, nsImage.size.height)
                            )
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
        } else {
            Text("Cannot preview image")
        }
    }

}
