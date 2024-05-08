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
/// WorkspacePDFView(fileURL)
///     .padding(.top, tabBarHeight)
///     .padding(.bottom, statusBarHeight)
/// ```
///
/// This view has the same context menu available in the native MacOS Preview application.
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
