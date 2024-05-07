//
//  WorkspacePdfFileView.swift
//  CodeEdit
//
//  Created by Paul Ebose on 2024/5/7.
//

import SwiftUI
import PDFKit.PDFView

/// A SwiftUI view for previewing a PDF file.
///
/// It takes in a file URL and attempts to preview a PDF.
///
/// **Example Usage**:
/// ```swift
/// WorkspacePdfFileView(fileURL)
///     .padding(.top, tabBarHeight)
///     .padding(.bottom, statusBarHeight)
/// ```
///
/// This view has the same context menu available in the native MacOS Preview application.
struct WorkspacePdfFileView: NSViewRepresentable {
    
    private let fileURL: URL
    
    /// - Parameter fileURL: URL to the PDF file you want to preview.
    init(_ fileURL: URL) {
        self.fileURL = fileURL
    }
    
    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: fileURL)
        pdfView.backgroundColor = NSColor.windowBackgroundColor
        return pdfView
    }
    
    func updateNSView(_ pdfView: PDFView, context: Context) {
        pdfView.document = PDFDocument(url: fileURL)
    }
    
}
