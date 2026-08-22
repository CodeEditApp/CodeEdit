//
//  StatusBarFileInfoView.swift
//  CodeEdit
//
//  Created by Paul Ebose on 2024/5/12.
//

import SwiftUI
import AppKit
import CodeEditCore
import UniformTypeIdentifiers

struct StatusBarFileInfoView: View {

    @EnvironmentObject private var statusBarViewModel: StatusBarViewModel
    @Environment(\.activeEditorState)
    private var activeEditorState

    @State private var fileSize: Int?
    @State private var dimensions: ImageDimensions?

    private let dimensionsNumberStyle = IntegerFormatStyle<Int>(locale: Locale(identifier: "en_US")).grouping(.never)

    var body: some View {

        HStack(spacing: 15) {

            if let dimensions {
                let width = dimensionsNumberStyle.format(dimensions.width)
                let height = dimensionsNumberStyle.format(dimensions.height)

                Text("\(width) × \(height)")
            }

            if let fileSize {
                Text(fileSize.formatted(.byteCount(style: .memory)))
            }

        }
        .font(statusBarViewModel.statusBarFont)
        .foregroundStyle(statusBarViewModel.foregroundStyle)
        .onReceive(activeEditorState.selectedFilePublisher) { file in
            updateFileInfo(for: file)
        }
    }

    private func updateFileInfo(for file: CEWorkspaceFile?) {
        guard let file,
              let resourceValues = try? file.url.resourceValues(forKeys: [.contentTypeKey, .fileSizeKey]),
              let contentType = resourceValues.contentType,
              let newFileSize = resourceValues.fileSize,
              !contentType.conforms(to: .text)
        else {
            fileSize = nil
            dimensions = nil
            return
        }

        fileSize = newFileSize

        if contentType.conforms(to: .image),
           let imageReps = NSImage(contentsOf: file.url)?.representations.first {
            dimensions = ImageDimensions(
                width: imageReps.pixelsWide,
                height: imageReps.pixelsHigh
            )
        } else {
            dimensions = nil
        }
    }
}
