//
//  AnyFileView.swift
//  CodeEdit
//
//  Created by Leonardo Larrañaga on 7/10/24.
//

import SwiftUI
import QuickLookUI

/// A view to preview any file using Quick Look.
/// ` AnyFileView(fileURL) `
struct AnyFileView: NSViewRepresentable {
    private let fileURL: URL

    init(_ fileURL: URL) {
        self.fileURL = fileURL
    }

    func makeNSView(context: Context) -> QLPreviewView {
        let previewView = QLPreviewView(frame: .zero, style: .normal)!
        previewView.previewItem = fileURL as QLPreviewItem
        return previewView
    }

    func updateNSView(_ nsView: QLPreviewView, context: Context) {
        nsView.previewItem = fileURL as QLPreviewItem
    }
}
