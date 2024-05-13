//
//  UpdateStatusBarInfo.swift
//  CodeEdit
//
//  Created by Paul Ebose on 2024/5/12.
//

import SwiftUI

/// Updates ``StatusBarFileInfoView``'s `fileSize` and `dimensions`.
/// ```swift
/// FileView
///   .modifier(UpdateStatusBarInfo(withURL))
/// ```
struct UpdateStatusBarInfo: ViewModifier {

    /// The URL of the file to compute information from.
    let withURL: URL

    @EnvironmentObject private var editorManager: EditorManager
    @EnvironmentObject private var statusBarViewModel: StatusBarViewModel

    /// This is returned by ``UpdateStatusBarInfo`` `.computeStatusBarInfo`.
    private struct ComputedStatusBarInfo {
        let fileSize: Int
        let dimensions: ImageDimensions?
    }

    /// Compute information that can be used to update properties in ``StatusBarFileInfoView``.
    /// - Parameter url: URL of the file to compute information from.
    /// - Returns: The file size and its image dimensions (if any).
    private func computeStatusBarInfo(url: URL) -> ComputedStatusBarInfo? {
        guard let resourceValues = try? url.resourceValues(forKeys: [.contentTypeKey, .fileSizeKey]),
              let contentType = resourceValues.contentType,
              let fileSize = resourceValues.fileSize
        else {
            return nil
        }

        if contentType.conforms(to: .image), let imageReps = NSImage(contentsOf: url)?.representations.first {
            let dimensions = ImageDimensions(width: imageReps.pixelsWide, height: imageReps.pixelsHigh)
            return ComputedStatusBarInfo(fileSize: fileSize, dimensions: dimensions)
        } else { // non-image file
            return ComputedStatusBarInfo(fileSize: fileSize, dimensions: nil)
        }
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                let statusBarInfo = computeStatusBarInfo(url: withURL)
                statusBarViewModel.fileSize = statusBarInfo?.fileSize
                statusBarViewModel.dimensions = statusBarInfo?.dimensions
            }
            .onChange(of: editorManager.activeEditor.selectedTab) { newTab in
                guard let newTab else { return }
                let statusBarInfo = computeStatusBarInfo(url: newTab.file.url)
                statusBarViewModel.fileSize = statusBarInfo?.fileSize
                statusBarViewModel.dimensions = statusBarInfo?.dimensions
            }
    }

}
