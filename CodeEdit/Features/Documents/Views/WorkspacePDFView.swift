//
//  WorkspacePDFView.swift
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
/// WorkspacePDFView(documentURL)
///     .padding(.top, tabBarHeight)
///     .padding(.bottom, statusBarHeight)
/// ```
///
/// This view provides a context menu that is the same as the one in the
/// native MacOS Preview application, for PDF files.
struct WorkspacePDFView: NSViewRepresentable {

    /// URL of the PDF file you want to preview.
    let fileURL: URL

    init(_ fileURL: URL) {
        self.fileURL = fileURL
    }

    func makeNSView(context: Context) -> PDFView {
        let pdfView = attachPDFDocumentToView(PDFView())
        return pdfView
    }

    func updateNSView(_ pdfView: PDFView, context: Context) {
        attachPDFDocumentToView(pdfView)
    }

    /// Creates a PDF document using ``WorkspacePDFView/fileURL``, and attaches it to the passed in `pdfView`.
    /// - Parameters:
    ///   - pdfView: The [`PDFView`](https://developer.apple.com/documentation/pdfkit/pdfview) you wish to modify.
    /// - Returns: A modified `pdfView` if a valid PDF was created, or an unmodified `pdfView` if it could not create a
    /// valid PDF.
    @discardableResult
    private func attachPDFDocumentToView (_ pdfView: PDFView) -> PDFView {
        guard let pdfDocument = PDFDocument(url: fileURL) else {
            // what can happen is the view doesn't redraw, so whatever was in the tab content view remains as is.
            return pdfView
        }
        pdfView.document = pdfDocument
        pdfView.backgroundColor = NSColor.controlBackgroundColor
        return pdfView
    }

}
