//
//  FileItem.swift
//  CodeEditModules/WorkspaceClient
//
//  Created by Marco Carnevali on 16/03/22.
//

import Foundation
import SwiftUI
import TabBar
import UniformTypeIdentifiers

public extension WorkspaceClient {
    enum FileItemCodingKeys: String, CodingKey {
        case id
        case url
        case children
    }

    /// An object containing all necessary information and actions for a specific file in the workspace
    final class FileItem: Identifiable, Codable, TabBarItemRepresentable {
        public var tabID: TabBarItemID {
            .codeEditor(id)
        }

        public var title: String {
            url.lastPathComponent
        }

        public var icon: Image {
            Image(systemName: systemImage)
        }

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
                return FileIcon.fileIcon(fileType: fileType)
            case let .some(children):
                return folderIcon(children)
            }
        }

        /// Returns the file name (e.g.: `Package.swift`)
        public var fileName: String {
            url.lastPathComponent
        }

        /// Returns the extension of the file or an empty string if no extension is present.
        public var fileType: FileIcon.FileType {
            .init(rawValue: url.pathExtension) ?? .txt
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

        /// Returns the file name with optional extension (e.g.: `Package.swift`)
        public func fileName(typeHidden: Bool) -> String {
            typeHidden ? url.deletingPathExtension().lastPathComponent : fileName
        }

        /// Return the file's UTType
        public var contentType: UTType? {
            try? url.resourceValues(forKeys: [.contentTypeKey]).contentType
        }

        /// Returns a `Color` for a specific `fileType`
        ///
        /// If not specified otherwise this will return `Color.accentColor`
        public var iconColor: Color {
            FileIcon.iconColor(fileType: fileType)
        }

        // MARK: Statics

        /// The default `FileManager` instance
        public static let fileManger = FileManager.default

        // MARK: Intents

        /// Allows the user to view the file or folder in the finder application
        public func showInFinder() {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }

        /// Allows the user to launch the file or folder as it would be in finder
        public func openWithExternalEditor() {
            NSWorkspace.shared.open(url)
        }

        /// This function allows creation of folders in the main directory or sub-folders
        /// - Parameter folderName: The name of the new folder
        public func addFolder(folderName: String) {
            // check if folder, if it is create folder under self, else create on same level.
            var folderUrl = (self.isFolder ?
                             self.url.appendingPathComponent(folderName) :
                                self.url.deletingLastPathComponent().appendingPathComponent(folderName))

            // if a file/folder with the same name exists, add a number to the end.
            var fileNumber = 0
            while FileItem.fileManger.fileExists(atPath: folderUrl.path) {
                fileNumber += 1
                folderUrl = folderUrl.deletingLastPathComponent().appendingPathComponent("\(folderName)\(fileNumber)")
            }

            // create the folder
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
            // check if folder, if it is create file under self
            var fileUrl = (self.isFolder ?
                       self.url.appendingPathComponent(fileName) :
                        self.url.deletingLastPathComponent().appendingPathComponent(fileName))

            // if a file/folder with the same name exists, add a number to the end.
            var fileNumber = 0
            while FileItem.fileManger.fileExists(atPath: fileUrl.path) {
                fileNumber += 1
                fileUrl = fileUrl.deletingLastPathComponent().appendingPathComponent("\(fileName)\(fileNumber)")
            }

            // create the file
            FileItem.fileManger.createFile(
                atPath: fileUrl.path,
                contents: nil,
                attributes: [FileAttributeKey.creationDate: Date()]
            )
        }

        /// This function deletes the item or folder from the current project
        public func delete() {
            // this function also has to account for how the
            // file system can change outside of the editor

            let deleteConfirmation = NSAlert()
            let message = "\(self.fileName)\(self.isFolder ? " and its children" :"")"
            deleteConfirmation.messageText = "Do you want to move \(message) to the bin?"
            deleteConfirmation.alertStyle = .critical
            deleteConfirmation.addButton(withTitle: "Delete")
            deleteConfirmation.buttons.last?.hasDestructiveAction = true
            deleteConfirmation.addButton(withTitle: "Cancel")
            if deleteConfirmation.runModal() == .alertFirstButtonReturn { // "Delete" button
                if FileItem.fileManger.fileExists(atPath: self.url.path) {
                    do {
                        try FileItem.fileManger.removeItem(at: self.url)
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }

        /// This function duplicates the item or folder
        public func duplicate() {
            // if a file/folder with the same name exists, add "copy" to the end
            var fileUrl = self.url
            while FileItem.fileManger.fileExists(atPath: fileUrl.path) {
                let previousName = fileUrl.lastPathComponent
                fileUrl = fileUrl.deletingLastPathComponent().appendingPathComponent("\(previousName) copy")
            }

            if FileItem.fileManger.fileExists(atPath: self.url.path) {
                do {
                    try FileItem.fileManger.copyItem(at: self.url, to: fileUrl)
                } catch {
                    print("Error at \(self.url.path) to \(fileUrl.path)")
                    fatalError(error.localizedDescription)
                }
            }
        }

        /// This function moves the item or folder if possible
        public func move(to newLocation: URL) {
            guard !FileItem.fileManger.fileExists(atPath: newLocation.path) else { return }
            do {
                try FileItem.fileManger.moveItem(at: self.url, to: newLocation)
            } catch { fatalError(error.localizedDescription) }
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
        lhs.id == rhs.id
    }

    public static func < (lhs: WorkspaceClient.FileItem, rhs: WorkspaceClient.FileItem) -> Bool {
        lhs.url.lastPathComponent < rhs.url.lastPathComponent
    }
}

public extension Array where Element: Hashable {

    // TODO: DOCS (Marco Carnevali)
    // swiftlint:disable:next missing_docs
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
