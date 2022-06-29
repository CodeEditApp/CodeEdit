//
//  ImageFileView.swift
//  CodeEditModules/CodeFile
//
//  Created by Nanashi Li on 2022/04/16.
//

import SwiftUI

public struct ImageFileView: View {

    @ObservedObject
    private var imageFile: CodeFileDocument

    public init(imageFile: CodeFileDocument) {
        self.imageFile = imageFile
    }

    public var body: some View {
        GeometryReader { proxy in
            if let image = imageFile.image {
                if image.size.width > proxy.size.width || image.size.height > proxy.size.height {
                    ScrollView {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: proxy.size.width)
                    }
                    .frame(maxHeight: .infinity)
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
