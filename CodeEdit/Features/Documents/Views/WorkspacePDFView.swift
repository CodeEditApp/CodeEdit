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
/// When a valid PDF is created, the `canPreviewFile` boolean updates to `true`.
///
/// **Example Usage**:
/// ```swift
/// WorkspacePDFView(
///     fileURL: documentURL,
///     canPreviewFile: $canPreviewFile
/// )
///     .padding(.top, tabBarHeight)
///     .padding(.bottom, statusBarHeight)
/// ```
///
/// This view provides a context menu that is the same as the one in the
/// native MacOS Preview application, for PDF files.
struct WorkspacePDFView: NSViewRepresentable {

    /// URL of the PDF file you want to preview.
    let fileURL: URL
    /// This value updates after attempting to create a valid PDF.
    ///
    /// `true` when created successfully, and `false` when failed to create.
    @Binding var canPreviewFile: Bool

    func makeNSView(context: Context) -> PDFView {
        let pdfView = attachPDFDocumentToView(PDFView(), context: context)
        return pdfView
    }

    func updateNSView(_ pdfView: PDFView, context: Context) {
        attachPDFDocumentToView(pdfView, context: context)
    }

    func makeCoordinator() -> WorkspacePDFView.Coordinator {
        // The coordinator object implements the mechanics of passing
        // data between the NS view representable and Swift UI.
        Coordinator(self)
    }

    final class Coordinator {
        let pdfView: WorkspacePDFView
        init(_ pdfView: WorkspacePDFView) {
            self.pdfView = pdfView
        }
    }

    /// Creates a PDF document using ``WorkspacePDFView/fileURL``, and attaches it to the passed in `pdfView`.
    /// - Parameters:
    ///   - pdfView: The [`PDFView`](https://developer.apple.com/documentation/pdfkit/pdfview) you wish to modify.
    ///   - context: The NS view representable context for ``WorkspacePDFView``. This is used to access the coordinator.
    /// - Returns: A modified `pdfView` if a valid document was created, or an unmodified `pdfView` if a valid
    /// document could not be created.
    @discardableResult private func attachPDFDocumentToView (_ pdfView: PDFView, context: Context) -> PDFView {
        // use the coordinator to update the state binding
        guard let pdfDocument = PDFDocument(url: fileURL) else {
            context.coordinator.pdfView.canPreviewFile = false
            return pdfView
        }
        context.coordinator.pdfView.canPreviewFile = true
        pdfView.document = pdfDocument
        pdfView.backgroundColor = NSColor.windowBackgroundColor
        return pdfView
    }

}
