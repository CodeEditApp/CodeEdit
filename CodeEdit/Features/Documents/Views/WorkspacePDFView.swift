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
/// When a valid PDF view is created, the `canPreviewFile` boolean updates to `true`.
///
/// **Example Usage**:
/// ```swift
/// WorkspacePDFView(
///     fileUrl: documentURL,
///     canPreviewFile: $canPreviewFile
/// )
///     .padding(.top, tabBarHeight)
///     .padding(.bottom, statusBarHeight)
/// ```
///
/// This view provides a context menu that is the same as the one in the native MacOS Preview application, for PDF files.
struct WorkspacePDFView: NSViewRepresentable {

    let fileURL: URL
    @Binding var canPreviewFile: Bool

    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: fileURL)
        if pdfView.document != nil {
            // use the coordinator to update the binding
            context.coordinator.pdfView.canPreviewFile = true
        }
        pdfView.backgroundColor = NSColor.windowBackgroundColor
        return pdfView
    }

    func updateNSView(_ nsView: PDFView, context: Context) {
        nsView.document = PDFDocument(url: fileURL)
    }

    func makeCoordinator() -> WorkspacePDFView.Coordinator {
        // The coordinator object implements the mechanics of passing
        // data between the NS view representable and Swift UI.
        Coordinator(self)
    }

    final class Coordinator: NSObject {
        let pdfView: WorkspacePDFView
        init(_ pdfView: WorkspacePDFView) {
            self.pdfView = pdfView
        }
    }
}
