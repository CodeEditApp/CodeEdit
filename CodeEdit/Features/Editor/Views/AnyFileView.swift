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
    private let fileURL: NSURL

    init(_ fileURL: URL) {
        self.fileURL = fileURL as NSURL
    }

    func makeNSView(context: Context) -> QLPreviewView {
        let qlPreviewView = QLPreviewView()
        qlPreviewView.previewItem = fileURL
        qlPreviewView.shouldCloseWithWindow = false // Temp work around for something more reasonable.
        return qlPreviewView
    }

    func updateNSView(_ qlPreviewView: QLPreviewView, context: Context) {
        qlPreviewView.previewItem = fileURL
    }

    // Temp work around for something more reasonable.
    // Open quickly should empty the results (but cache the query) when closed,
    // and then re-search or recompute the results when re-opened.
    static func dismantleNSView(_ qlPreviewView: QLPreviewView, coordinator: ()) {
        qlPreviewView.close()
    }
}
