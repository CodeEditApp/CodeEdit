//
//  URL+isImage.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 14/05/23.
//

import Foundation

extension URL {
    func isImage() -> Bool {
        let ext: String = self.pathExtension

        // A list of supported file types by QLPreviewItem
        // Some of the image file types (in UTType) are not supported by QLPreviewItem
        let quickLookImageFileTypes: [String] = [
            "png",
            "jpg",
            "jpeg",
            "bmp",
            "pdf",
            "heic",
            "webp",
            "tiff",
            "gif",
            "tga",
            "avif",
            "psd",
            "svg"
        ]

        if quickLookImageFileTypes.contains(ext) {
            return true
        } else {
            return false
        }
    }
}
