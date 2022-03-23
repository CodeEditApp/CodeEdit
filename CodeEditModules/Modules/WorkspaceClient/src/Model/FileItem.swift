//
//  FileItem.swift
//  CodeEdit
//
//  Created by Marco Carnevali on 16/03/22.
//

import Foundation
import SwiftUI

public extension WorkspaceClient {
    struct FileItem: Hashable, Identifiable, Comparable, Codable {
        // TODO: use a phantom type instead of a String
        public var id: String
        public var url: URL
        public var children: [FileItem]?
        public static let fileManger = FileManager.default
        public var systemImage: String {
            switch children {
            case nil:
                return fileIcon
            case let .some(children):
                return children.isEmpty ? "folder" : "folder.fill"
            }
        }

        public var fileName: String {
            url.lastPathComponent
        }

        public var fileIcon: String {
            switch fileType {
            case "json", "js":
                return "curlybraces"
            case "css":
                return "number"
            case "jsx":
                return "atom"
            case "swift":
                return "swift"
            case "env":
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
            default:
                return "doc"
            }
        }

        public var iconColor: Color {
            switch fileType {
            case "swift", "html":
                return .orange
            case "java":
                return .red
            case "js", "entitlements", "json", "LICENSE":
                return .yellow
            case "css", "ts", "jsx", "md", "py":
                return .blue
            case "sh":
                return .green
            default:
                return .blue
            }
        }

        private var fileType: String {
            url.lastPathComponent.components(separatedBy: ".").last ?? ""
        }

        public init(
            url: URL,
            children: [FileItem]? = nil
        ) {
            self.url = url
            self.children = children
            id = url.relativePath
        }

        public static func == (lhs: FileItem, rhs: FileItem) -> Bool {
            return lhs.id == rhs.id
        }

        public static func < (lhs: FileItem, rhs: FileItem) -> Bool {
            return lhs.url.lastPathComponent < rhs.url.lastPathComponent
        }

        /// Allows the user to view the file or folder in the finder application
        public func showInFinder() {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }

        /// This function allows creation of folders in the main directory or sub-folders
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
        public func addFile(fileName: String) {
            do {
                let fileUrl = url.appendingPathComponent(fileName)
                FileItem.fileManger.createFile(
                    atPath: fileUrl.path,
                    contents: nil,
                    attributes: [FileAttributeKey.creationDate: Date()])
            } catch {
                fatalError(error.localizedDescription)
            }
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

public extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
