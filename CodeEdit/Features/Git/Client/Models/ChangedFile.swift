//
//  ChangedFile.swift
//  
//
//  Created by Nanashi Li on 2022/05/20.
//

import Foundation
import SwiftUI

struct ChangedFile: Codable, Hashable, Identifiable {
    /// ID of the changed file
    var id = UUID()

    /// Change type is to tell us whether the type is a new file, modified or deleted
    let changeType: GitType?

    /// Link of the file
    let fileLink: URL

    /// Use it like this
    /// ```swift
    /// Image(systemName: item.systemImage)
    /// ```
    var systemImage: String {
        if fileLink.hasDirectoryPath {
            return "folder.fill"
        } else {
            return FileIcon.fileIcon(fileType: fileType)
        }
    }

    /// Returns the file name (e.g.: `Package.swift`)
    var fileName: String {
        fileLink.deletingPathExtension().lastPathComponent
    }

    var changeTypeValue: String {
        changeType?.description ?? ""
    }

    /// Returns the extension of the file or an empty string if no extension is present.
    private var fileType: FileIcon.FileType {
        .init(rawValue: fileLink.pathExtension) ?? .txt
    }

    /// Returns a `Color` for a specific `fileType`
    ///
    /// If not specified otherwise this will return `Color.accentColor`
    var iconColor: Color {
        FileIcon.iconColor(fileType: fileType)
    }

    // MARK: Intents
    /// Allows the user to view the file or folder in the finder application
    func showInFinder(workspaceURL: URL) {
        let workspace = workspaceURL.absoluteString
        let file = fileLink.absoluteString
        guard let url = URL(string: workspace + file) else {
            return print("Failed to decode URL")
        }
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}
