//
//  ImageFileView.swift
//  CodeEditModules/CodeFile
//
//  Created by Nanashi Li on 2022/04/16.
//

import SwiftUI

public struct ImageFileView: View {

    private let image: NSImage?

    public init(image: NSImage?) {
        self.image = image
    }

    public var body: some View {
        GeometryReader { proxy in
            if let image = image {
                if image.size.width > proxy.size.width || image.size.height > proxy.size.height {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(nsImage: image)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                }
            } else {
                EmptyView()
            }
        }
    }
}
