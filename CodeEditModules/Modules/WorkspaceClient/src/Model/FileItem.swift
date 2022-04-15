//
//  FileItem.swift
//  CodeEdit
//
//  Created by Marco Carnevali on 16/03/22.
//

import Foundation
import SwiftUI

public extension WorkspaceClient {
    enum FileItemCodingKeys: String, CodingKey {
        case id
        case url
        case children
    }

    /// An object containing all necessary information and actions for a specific file in the workspace
    final class FileItem: Identifiable, Codable {

        public typealias ID = String

        public init(
            url: URL,
            children: [FileItem]? = nil
        ) {
            self.url = url
            self.children = children
            id = url.relativePath
        }

        public required init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: FileItemCodingKeys.self)
            id = try values.decode(String.self, forKey: .id)
            url = try values.decode(URL.self, forKey: .url)
            children = try values.decode([FileItem]?.self, forKey: .children)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: FileItemCodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(url, forKey: .url)
            try container.encode(children, forKey: .children)
        }

        /// The id of the ``WorkspaceClient/WorkspaceClient/FileItem``.
        ///
        /// This is equal to `url.relativePath`
        public var id: ID

        /// Returns the URL of the ``WorkspaceClient/WorkspaceClient/FileItem``
        public var url: URL

        /// Returns the children of the current ``WorkspaceClient/WorkspaceClient/FileItem``.
        ///
        /// If the current ``WorkspaceClient/WorkspaceClient/FileItem`` is a file this will be `nil`.
        /// If it is an empty folder this will be an empty array.
        public var children: [FileItem]?

        /// Returns a parent ``WorkspaceClient/WorkspaceClient/FileItem``.
        ///
        /// If the item already is the top-level ``WorkspaceClient/WorkspaceClient/FileItem`` this returns `nil`.
        public var parent: FileItem?

        /// A boolean that is true if ``children`` is not `nil`
        public var isFolder: Bool {
            children != nil
        }

        /// A boolean that is true if the file item is the root folder of the workspace.
        public var isRoot: Bool {
            parent == nil
        }

        /// Returns a string describing a SFSymbol for the current ``WorkspaceClient/WorkspaceClient/FileItem``
        ///
        /// Use it like this
        /// ```swift
        /// Image(systemName: item.systemImage)
        /// ```
        public var systemImage: String {
            switch children {
            case nil:
                return fileIcon
            case let .some(children):
                return folderIcon(children)
            }
        }

        /// Returns the file name (e.g.: `Package.swift`)
        public var fileName: String {
            url.lastPathComponent
        }

        /// Returns the extension of the file or an empty string if no extension is present.
        private var fileType: String {
            url.lastPathComponent.components(separatedBy: ".").last ?? ""
        }

        /// Returns a string describing a SFSymbol for folders
        ///
        /// If it is the top-level folder this will return `"square.dashed.inset.filled"`.
        /// If it is a `.codeedit` folder this will return `"folder.fill.badge.gearshape"`.
        /// If it has children this will return `"folder.fill"` otherwise `"folder"`.
        private func folderIcon(_ children: [FileItem]) -> String {
            if self.parent == nil {
                return "square.dashed.inset.filled"
            }
            if self.fileName == ".codeedit" {
                return "folder.fill.badge.gearshape"
            }
            return children.isEmpty ? "folder" : "folder.fill"
        }

        /// Returns a string describing a SFSymbol for files
        ///
        /// If not specified otherwise this will return `"doc"`
        private var fileIcon: String {
            switch fileType {
            case "json", "js":
                return "curlybraces"
            case "css":
                return "number"
            case "jsx":
                return "atom"
            case "swift":
                return "swift"
            case "env", "example":
                return "gearshape.fill"
            case "gitignore":
                return "arrow.triangle.branch"
            case "png", "jpg", "jpeg", "ico":
                return "photo"
            case "svg":
                return "square.fill.on.circle.fill"
            case "entitlements":
                return "checkmark.seal"
            case "plist":
                return "tablecells"
            case "md", "txt", "rtf":
                return "doc.plaintext"
            case "html", "py", "sh":
                return "chevron.left.forwardslash.chevron.right"
            case "LICENSE":
                return "key.fill"
            case "java":
                return "cup.and.saucer"
            case "h":
                return "h.square"
            case "m":
                return "m.square"
            case "vue":
                return "v.square"
            case "go":
                return "g.square"
            case "sum":
                return "s.square"
            case "mod":
                return "m.square"
            case "Makefile":
                return "terminal"
            default:
                return "doc"
            }
        }

        /// Returns a `Color` for a specific `fileType`
        ///
        /// If not specified otherwise this will return `Color.accentColor`
        public var iconColor: Color {
            switch fileType {
            case "swift", "html":
                return .orange
            case "java":
                return .red
            case "js", "entitlements", "json", "LICENSE":
                return Color("SidebarYellow")
            case "css", "ts", "jsx", "md", "py":
                return .blue
            case "sh":
                return .green
            case "vue":
                return Color(red: 0.255, green: 0.722, blue: 0.514, opacity: 1.000)
            case "h":
                return Color(red: 0.667, green: 0.031, blue: 0.133, opacity: 1.000)
            case "m":
                return Color(red: 0.271, green: 0.106, blue: 0.525, opacity: 1.000)
            case "go":
                return Color(red: 0.02, green: 0.675, blue: 0.757, opacity: 1.0)
            case "sum", "mod":
                return Color(red: 0.925, green: 0.251, blue: 0.478, opacity: 1.0)
            case "Makefile":
                return Color(red: 0.937, green: 0.325, blue: 0.314, opacity: 1.0)
            default:
                return .accentColor
            }
        }

        // MARK: Statics

        /// The default `FileManager` instance
        public static let fileManger = FileManager.default

        // MARK: Intents

        /// Allows the user to view the file or folder in the finder application
        public func showInFinder() {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }

        /// This function allows creation of folders in the main directory or sub-folders
        /// - Parameter folderName: The name of the new folder
        public func addFolder(folderName: String) {
            let folderUrl = url.appendingPathComponent(folderName)
            do {
                try FileItem.fileManger.createDirectory(at: folderUrl,
                                                        withIntermediateDirectories: true,
                                                        attributes: [:])
            } catch {
                fatalError(error.localizedDescription)
            }
        }

        /// This function allows creating files in the selected folder or project main directory
        /// - Parameter fileName: The name of the new file
        public func addFile(fileName: String) {
            let fileUrl = url.appendingPathComponent(fileName)
            FileItem.fileManger.createFile(
                atPath: fileUrl.path,
                contents: nil,
                attributes: [FileAttributeKey.creationDate: Date()]
            )
        }

        /// This function deletes the item or folder from the current project
        public func delete() {
            if FileItem.fileManger.fileExists(atPath: url.path) {
                do {
                    try FileItem.fileManger.removeItem(at: url)
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: Hashable

extension WorkspaceClient.FileItem: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(url)
        hasher.combine(children)
    }
}

// MARK: Comparable

extension WorkspaceClient.FileItem: Comparable {
    public static func == (lhs: WorkspaceClient.FileItem, rhs: WorkspaceClient.FileItem) -> Bool {
        return lhs.id == rhs.id
    }

    public static func < (lhs: WorkspaceClient.FileItem, rhs: WorkspaceClient.FileItem) -> Bool {
        return lhs.url.lastPathComponent < rhs.url.lastPathComponent
    }
}

public extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
