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

    class FileItem: Hashable, Identifiable, Comparable, Codable {
        // TODO: use a phantom type instead of a String
        public var id: String
        public var url: URL
        public var children: [FileItem]?
        public var parent: FileItem?
        public static let fileManger = FileManager.default
        public var systemImage: String {
            switch children {
            case nil:
                return fileIcon
            case let .some(children):
                if self.parent == nil {
                    return "square.dashed.inset.filled"
                }
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

        // MARK: Hashable

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(url)
            hasher.combine(children)
        }

        // MARK: Codable

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: FileItemCodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(url, forKey: .url)
            try container.encode(children, forKey: .children)
        }

        public required init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: FileItemCodingKeys.self)
            id = try values.decode(String.self, forKey: .id)
            url = try values.decode(URL.self, forKey: .url)
            children = try values.decode([FileItem]?.self, forKey: .children)
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
