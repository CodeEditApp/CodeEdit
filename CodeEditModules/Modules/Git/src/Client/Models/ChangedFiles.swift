//
//  ChangedFiles.swift
//  
//
//  Created by Nanashi Li on 2022/05/05.
//

import Foundation
import SwiftUI
import WorkspaceClient

public struct ChangedFiles: Codable, Hashable, Identifiable {
    public var id = UUID()
    public var changeType: String
    public var fileLink: String

    /// Use it like this
    /// ```swift
    /// Image(systemName: item.systemImage)
    /// ```
    public var systemImage: String {
        if !isFile {
            return "folder.fill"
        } else {
            return FileIcon.fileIcon(fileType: fileType)
        }
    }

    /// Returns the file name (e.g.: `Package.swift`)
    public var fileName: String {
        URL(string: fileLink)?.lastPathComponent ?? ""
    }

    private var isFile: Bool {
        return fileName.contains(".")
    }

    /// Returns the extension of the file or an empty string if no extension is present.
    private var fileType: String {
        URL(string: fileLink)?.lastPathComponent.components(separatedBy: ".").last ?? ""
    }

    /// Returns a `Color` for a specific `fileType`
    ///
    /// If not specified otherwise this will return `Color.accentColor`
    public var iconColor: Color {
        return FileIcon.iconColor(fileType: fileType)
    }

    // MARK: Intents

    /// Allows the user to view the file or folder in the finder application
    public func showInFinder(workspaceURL: URL) {
        let workspace = workspaceURL.absoluteString
        let url = URL(string: workspace + fileLink)!
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}
