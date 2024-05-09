//
//  WorkspaceImageView.swift
//  CodeEdit
//
//  Created by Paul Ebose on 2024/5/9.
//

import SwiftUI

struct WorkspaceImageView: View {

    /// URL of the image you want to preview.
    let imageUrl: URL

    var body: some View {
        if let nsImage = NSImage(contentsOf: imageUrl),
           let imageReps = nsImage.representations.first {
            // ---
            let pixelWidth = CGFloat(imageReps.pixelsWide)
            let pixelHeight = CGFloat(imageReps.pixelsHigh)

            GeometryReader { proxy in
                ZStack {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            maxWidth: min(pixelWidth, proxy.size.width, nsImage.size.width),
                            maxHeight: min(pixelHeight, proxy.size.height, nsImage.size.height)
                        )
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
        } else {
            WorkspaceCannotPreviewFileView()
        }
    }

}
