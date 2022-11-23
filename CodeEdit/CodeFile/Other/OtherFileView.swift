//
//  OtherFileView.swift
//  
//
//  Created by Shibo Tong on 10/7/2022.
//

import SwiftUI
import QuickLookUI

/// A SwiftUI Wrapper for `QLPreviewView`
/// Mainly used for other unsupported files
/// ## Usage
/// ```swift
/// OtherFileView(otherFile)
/// ```
struct OtherFileView: NSViewRepresentable {

    private var otherFile: CodeFileDocument

    /// Initialize the OtherFileView
    /// - Parameter otherFile: a file which contains URL to show preview
    init(
        _ otherFile: CodeFileDocument
    ) {
        self.otherFile = otherFile
    }

    func makeNSView(context: Context) -> QLPreviewView {
        let qlPreviewView = QLPreviewView()
        if let previewItemURL = otherFile.previewItemURL {
            qlPreviewView.previewItem = previewItemURL as QLPreviewItem
        }
        return qlPreviewView
    }

    /// Update preview file when file changed
    func updateNSView(_ nsView: QLPreviewView, context: Context) {
        guard let currentPreviewItem = nsView.previewItem else {
            return
        }
        if let previewItemURL = otherFile.previewItemURL, previewItemURL != currentPreviewItem.previewItemURL {
            nsView.previewItem = previewItemURL as QLPreviewItem
        }
    }
}
