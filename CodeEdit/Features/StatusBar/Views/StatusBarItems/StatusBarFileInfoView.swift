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
    @Environment(\.activeEditorState) private var activeEditorState

    private let dimensionsNumberStyle = IntegerFormatStyle<Int>(locale: Locale(identifier: "en_US")).grouping(.never)

    var body: some View {

        HStack(spacing: 15) {

            if let dimensions = statusBarViewModel.dimensions {
                let width = dimensionsNumberStyle.format(dimensions.width)
                let height = dimensionsNumberStyle.format(dimensions.height)

                Text("\(width) × \(height)")
            }

            if let fileSize = statusBarViewModel.fileSize {
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
              let fileSize = resourceValues.fileSize,
              !contentType.conforms(to: .text)
        else {
            statusBarViewModel.fileSize = nil
            statusBarViewModel.dimensions = nil
            return
        }

        statusBarViewModel.fileSize = fileSize

        if contentType.conforms(to: .image),
           let imageReps = NSImage(contentsOf: file.url)?.representations.first {
            statusBarViewModel.dimensions = ImageDimensions(
                width: imageReps.pixelsWide,
                height: imageReps.pixelsHigh
            )
        } else {
            statusBarViewModel.dimensions = nil
        }
    }
}
