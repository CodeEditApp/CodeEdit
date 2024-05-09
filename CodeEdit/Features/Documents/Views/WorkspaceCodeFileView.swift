//
//  WorkspaceCodeFileView.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI
import UniformTypeIdentifiers
import CodeEditSourceEditor
import AVKit
import PDFKit
import QuickLookUI
import QuickLook

struct WorkspaceCodeFileView: View {

    @EnvironmentObject private var editorManager: EditorManager

    @EnvironmentObject private var editor: Editor

    @Environment(\.edgeInsets)
    private var edgeInsets

    var file: CEWorkspaceFile
    var textViewCoordinators: [TextViewCoordinator] = []

    @State private var update: Bool = false

    @State private var canPreviewFile: Bool = false

    @ViewBuilder var codeView: some View {
        if let documentURL = file.fileDocument?.fileURL {

            //            WorkspacePDFView(fileUrl: documentURL, canPreviewFile: $canPreviewFile)
            // use the magic numbers to fine-tune its appearance
            //                .padding(.top, edgeInsets.top - 1.74)
            //                .padding(.bottom, StatusBarView.height + 1.26)

            GeometryReader { proxy in
                let nsImage = NSImage(contentsOf: documentURL)!
                let pixelWidth = CGFloat(nsImage.representations.first!.pixelsWide)
                let pixelHeight = CGFloat(nsImage.representations.first!.pixelsHigh)

                var _ = print("proxy.size:", proxy.size.width, proxy.size.height)
                var _ = print("pixels:", pixelWidth, pixelHeight)
                var _ = print("nsImage.size:", nsImage.size.width, nsImage.size.height)
                var _ = print("::::::::")

                ZStack {
                    Image(nsImage: nsImage)
                        .resizable()
                        .background(.red)
                        .scaledToFit()
                    // use the magic numbers to fine-tune its appearance
                    // .padding(.top, edgeInsets.top - 1.74)
                    // .padding(.bottom, StatusBarView.height + 1.26)
                    // .background(.blue)
                        .frame(
                            maxWidth: min(pixelWidth, proxy.size.width, nsImage.size.width),
                            maxHeight: min(pixelHeight, proxy.size.height, nsImage.size.height)
                        )
                    // .position(x: proxy.frame(in: .local).midX / 2, y: proxy.frame(in: .local).midY)
                        .background(.gray)
                        .border(.purple)
                }
                //                .padding(.leading, (proxy.size.width - pixelWidth) / 2)
                .frame(maxWidth: proxy.size.width / 2, maxHeight: proxy.size.height - 50)
                .background(.black)

            }
            .background(.teal)

            //            Group {
            //                switch document.typeOfFile {
            //                case .some(.text):
            //                        CodeFileView(codeFile: document, textViewCoordinators: textViewCoordinators)
            //                            .frame(maxWidth: .infinity, maxHeight: .infinity)

            //                case .some(.image):
            //                        OtherFileView(document)
            //            .padding(.bottom, workspaceStatusBarHeight)
            //                        GeometryReader { proxy in
            //                            let nsImg = NSImage(contentsOf: document.fileURL!)!
            //                            let pixelWidth = CGFloat(nsImg.representations.first!.pixelsWide)
            //                            let pixelHeight = CGFloat(nsImg.representations.first!.pixelsHigh)
            //
            //                            var _ = print("proxy.size:", proxy.size.width, proxy.size.height)
            //                            var _ = print("pixels:", pixelWidth, pixelHeight)
            //
            //                            if pixelWidth >= proxy.size.width || pixelHeight >= proxy.size.height {
            //                                Image(nsImage: nsImg)
            //                                    .resizable()
            //                                    .scaledToFit()
            //                                OtherFileView(document)
            //                                    .padding(.bottom, 25)
            //                                    //.containerRelativeFrame()
            //                            } else {
            //                                Image(nsImage: nsImg)
            //                                    .resizable()
            //                                    .frame(width: pixelWidth, height: pixelHeight)
            //                            }
            //                        }

            //                case .some(.audiovisualContent):
            //                        VideoPlayer(player: AVPlayer(playerItem: AVPlayerItem(url: document.fileURL!)))
            //                            .padding(.top, 80)
            //                            .padding(.bottom, 30)
            //
            //                default:
            //                        OtherFileView(document)
            //                            .padding(.bottom, 25)
            //                }
            //            }

        } else {
            if update {
                Spacer()
            }
            Spacer()
            VStack(spacing: 10) {
                ProgressView()
                Text("Opening \(file.name)...")
            }
            Spacer()
                .onAppear {
                    Task.detached {
                        let contentType = try await file.url.resourceValues(forKeys: [.contentTypeKey]).contentType
                        let codeFile = try await CodeFileDocument(
                            for: file.url,
                            withContentsOf: file.url,
                            ofType: contentType?.identifier ?? ""
                        )
                        await MainActor.run {
                            file.fileDocument = codeFile
                            CodeEditDocumentController.shared.addDocument(codeFile)
                            update.toggle()
                        }
                    }
                }
        }
    }

    @ViewBuilder
    private func otherFileView(
        _ otherFile: CodeFileDocument,
        for item: CEWorkspaceFile
    ) -> some View {
        VStack(spacing: 0) {
            if let url = otherFile.previewItemURL,
               let image = NSImage(contentsOf: url),
               otherFile.typeOfFile == .image {
                GeometryReader { proxy in
                    if image.size.width > proxy.size.width || image.size.height > proxy.size.height {
                        OtherFileView(otherFile)
                    } else {
                        OtherFileView(otherFile)
                            .frame(
                                width: proxy.size.width * (proxy.size.width / image.size.width),
                                height: proxy.size.height
                            )
                            .position(x: proxy.frame(in: .local).midX, y: proxy.frame(in: .local).midY)
                    }
                }
            } else {
                OtherFileView(otherFile)
            }
        }
    }

    var body: some View {
        codeView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onHover { hover in
                DispatchQueue.main.async {
                    if hover {
                        NSCursor.iBeam.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            }
    }
}
