//
//  AnyFileView.swift
//  CodeEdit
//
//  Created by Paul Ebose on 2024/5/9.
//

import SwiftUI
import QuickLookUI

/// A view for previewing any kind of file.
///
/// ```swift
/// AnyFileView(fileURL)
/// ```
/// If the file cannot be previewed, a file icon thumbnail is shown instead.
struct AnyFileView: NSViewRepresentable {

    /// URL of the file to preview. You can pass in any file type.
    private let fileURL: URL

    init(_ fileURL: URL) {
        self.fileURL = fileURL
    }

    func makeNSView(context: Context) -> QLPreviewView {
        let qlPreviewView = QLPreviewView()
        qlPreviewView.previewItem = fileURL as any QLPreviewItem
        return qlPreviewView
    }

    func updateNSView(_ qlPreviewView: QLPreviewView, context: Context) {
        qlPreviewView.previewItem = fileURL as any QLPreviewItem
    }

}
