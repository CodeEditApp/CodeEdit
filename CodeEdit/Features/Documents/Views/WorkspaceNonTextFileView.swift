//
//  WorkspaceNonTextFileView.swift
//  CodeEdit
//
//  Created by Paul Ebose on 2024/5/7.
//

//import SwiftUI
//import Quartz
//
//struct WorkspaceNonTextFileView: NSViewRepresentable {
//    // Properties: the file name (without extension), and whether we'll let
//    // the user scale the preview content.
//    private let file: CodeFileDocument
//
//    func makeCoordinator() -> WorkspaceNonTextFileView.QLCoordinator {
//        // The coordinator object implements the mechanics of dealing with
//        // the live UIKit view controller.
//        QLCoordinator(self)
//    }
//
//    func makeNSView(context: Context) -> QLPreviewView {
//        // Create the preview view, and assign our Coordinator class
//        // as its preview item.
//        let preview = QLPreviewView()
//        if let previewItem = file.previewItemURL {
//            preview.previewItem = previewItem as QLPreviewItem
//        }
//        //preview.previewItem = context.coordinator
//        return preview
//    }
//
//    func updateNSView(_ nsView: QLPreviewView, context: Context) {
//        // do nothing
//    }
//
//    class QLCoordinator: NSObject, QLPreviewPanelDataSource {
//        let parent: WorkspaceNonTextFileView
//        private lazy var fileURL: URL = Bundle.main.url(forResource: parent.name, withExtension: "reality")!
//
//        init(_ parent: WorkspaceNonTextFileView) {
//            self.parent = parent
//            super.init()
//        }
//
//        func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
//            return 1
//        }
//
//        func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> (any QLPreviewItem)! {
//            self.file
//        }
//
//        //        let parent: ARQuickLookView
//        //        private lazy var fileURL: URL = Bundle.main.url(forResource: parent.name,
//        //                                                        withExtension: "reality")!
//        //
//        //        init(_ parent: ARQuickLookView) {
//        //            self.parent = parent
//        //            super.init()
//        //        }
//        //
//        //        // The QLPreviewController asks its delegate how many items it has:
//        //        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
//        //            return 1
//        //        }
//        //
//        //        // For each item (see method above), the QLPreviewController asks for
//        //        // a QLPreviewItem instance describing that item:
//        //        func previewController(
//        //            _ controller: QLPreviewController,
//        //            previewItemAt index: Int
//        //        ) -> QLPreviewItem {
//        //            guard let fileURL = Bundle.main.url(forResource: parent.name, withExtension: "usdz") else {
//        //                fatalError("Unable to load \(parent.name).reality from main bundle")
//        //            }
//        //
//        //            let item = ARQuickLookPreviewItem(fileAt: fileURL)
//        //            item.allowsContentScaling = parent.allowScaling
//        //            return item
//        //        }
//
//    }
//}
//
////struct ContentView: View {
////    let qlCoordinator = QLCoordinator()
////
////    var body: some View {
////
////        // example.pdf is expected in app bundle resources
////        VStack {
////            MyPreview(fileName: "example.pdf")
////            Divider()
////            Button("Show panel") {
////                let panel = QLPreviewPanel.shared()
////                panel?.center()
////                panel?.dataSource = self.qlCoordinator
////                panel?.makeKeyAndOrderFront(nil)
////            }
////        }
////    }
////
////    class QLCoordinator: NSObject, QLPreviewPanelDataSource {
////        func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
////            return loadPreviewItem(with: "example.pdf") as QLPreviewItem
////        }
////
////        func numberOfPreviewItems(in controller: QLPreviewPanel) -> Int {
////            return 1
////        }
////    }
////}
//
////struct WorkspaceNonTextFileView_Previews: PreviewProvider {
////    static var previews: some View {
////        WorkspaceNonTextFileView(file:)
////    }
////}

