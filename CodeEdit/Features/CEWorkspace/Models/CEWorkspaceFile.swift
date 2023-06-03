//
//  FileItem.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 07/02/2023.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

enum FileItemCodingKeys: String, CodingKey {
    case id
    case url
    case children
    case changeType
}

/// An object containing all necessary information and actions for a specific file in the workspace
final class CEWorkspaceFile: Codable, Comparable, Hashable, Identifiable, TabBarItemRepresentable {

    /// The id of the ``FileSystemClient/FileSystemClient/FileItem``.
    ///
    /// This is equal to `url.relativePath`
    var id: String { url.relativePath }

    /// Returns the file name (e.g.: `Package.swift`)
    var name: String { url.lastPathComponent }

    /// Returns the extension of the file or an empty string if no extension is present.
    var type: FileIcon.FileType { .init(rawValue: url.pathExtension) ?? .txt }

    /// Returns the URL of the ``FileSystemClient/FileSystemClient/FileItem``
    var url: URL

    /// Return the icon of the file as `Image`
    var icon: Image { Image(systemName: systemImage) }

    /// Returns the children of the current ``FileSystemClient/FileSystemClient/FileItem``.
    ///
    /// If the current ``FileSystemClient/FileSystemClient/FileItem`` is a file this will be `nil`.
    /// If it is an empty folder this will be an empty array.
    var children: [CEWorkspaceFile]?

    /// Returns a parent ``FileSystemClient/FileSystemClient/FileItem``.
    ///
    /// If the item already is the top-level ``FileSystemClient/FileSystemClient/FileItem`` this returns `nil`.
    var parent: CEWorkspaceFile?

    var fileDocument: CodeFileDocument?

    var fileIdentifier = UUID().uuidString

    var watcher: DispatchSourceFileSystemObject?
    var watcherCode: ((CEWorkspaceFile) -> Void)?

    /// Returns the Git status of a file as ``GitType``
    var gitStatus: GitType?

    /// Returns the `id` in ``TabBarItemID`` enum form
    var tabID: TabBarItemID { .codeEditor(id) }

    /// Returns a boolean that is true if ``children`` is not `nil`
    var isFolder: Bool { url.hasDirectoryPath }

    /// Returns a boolean that is true if the file item is the root folder of the workspace.
    var isRoot: Bool { parent == nil }

    /// Returns a boolean that is true if the file item actually exists in the file system
    var doesExist: Bool { CEWorkspaceFile.fileManger.fileExists(atPath: self.url.path) }

    /// Returns a string describing a SFSymbol for the current ``FileSystemClient/FileSystemClient/FileItem``
    ///
    /// Use it like this
    /// ```swift
    /// Image(systemName: item.systemImage)
    /// ```
    var systemImage: String {
        if let children = children {
            // item is a folder
            return folderIcon(children)
        } else {
            // item is a file
            return FileIcon.fileIcon(fileType: type)
        }
    }

    /// Return the file's UTType
    var contentType: UTType? {
        try? url.resourceValues(forKeys: [.contentTypeKey]).contentType
    }

    /// Returns a `Color` for a specific `fileType`
    ///
    /// If not specified otherwise this will return `Color.accentColor`
    var iconColor: Color {
        FileIcon.iconColor(fileType: type)
    }

    var debugFileHeirachy: String { childrenDescription(tabCount: 0) }

    init(
        url: URL,
        children: [CEWorkspaceFile]? = nil,
        changeType: GitType? = nil
    ) {
        self.url = url
        self.children = children
        self.gitStatus = changeType
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: FileItemCodingKeys.self)
        url = try values.decode(URL.self, forKey: .url)
        children = try values.decode([CEWorkspaceFile]?.self, forKey: .children)
        gitStatus = try values.decode(GitType.self, forKey: .changeType)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: FileItemCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(url, forKey: .url)
        try container.encode(children, forKey: .children)
        try container.encode(gitStatus, forKey: .changeType)
    }

    func activateWatcher() -> Bool {
        guard let watcherCode else { return false }

        let descriptor = open(self.url.path, O_EVTONLY)
        guard descriptor > 0 else { return false }

        // create the source
        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: descriptor,
            eventMask: .write,
            queue: DispatchQueue.global()
        )

        if descriptor > 2000 {
            print("Watcher \(descriptor) used up on \(url.path)")
        }

        source.setEventHandler { watcherCode(self) }
        source.setCancelHandler { close(descriptor) }
        source.resume()
        self.watcher = source

        // TODO: reindex the current item, because the files in the item may have changed
        // since the initial load on startup.
        return true
    }

    /// Returns a string describing a SFSymbol for folders
    ///
    /// If it is the top-level folder this will return `"square.dashed.inset.filled"`.
    /// If it is a `.codeedit` folder this will return `"folder.fill.badge.gearshape"`.
    /// If it has children this will return `"folder.fill"` otherwise `"folder"`.
    private func folderIcon(_ children: [CEWorkspaceFile]) -> String {
        if self.parent == nil {
            return "folder.fill.badge.gearshape"
        }
        if self.name == ".codeedit" {
            return "folder.fill.badge.gearshape"
        }
        return children.isEmpty ? "folder" : "folder.fill"
    }

    /// Returns the file name with optional extension (e.g.: `Package.swift`)
    func fileName(typeHidden: Bool) -> String {
        typeHidden ? url.deletingPathExtension().lastPathComponent : name
    }

    // MARK: Statics
    /// The default `FileManager` instance
    static let fileManger = FileManager.default

    // MARK: Intents
    /// Allows the user to view the file or folder in the finder application
    func showInFinder() {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    /// Allows the user to launch the file or folder as it would be in finder
    func openWithExternalEditor() {
        NSWorkspace.shared.open(url)
    }

    /// This function allows creation of folders in the main directory or sub-folders
    /// - Parameter folderName: The name of the new folder
    func addFolder(folderName: String) {
        // Check if folder, if it is create folder under self, else create on same level.
        var folderUrl = (self.isFolder ?
                         self.url.appendingPathComponent(folderName) :
                            self.url.deletingLastPathComponent().appendingPathComponent(folderName))

        // If a file/folder with the same name exists, add a number to the end.
        var fileNumber = 0
        while CEWorkspaceFile.fileManger.fileExists(atPath: folderUrl.path) {
            fileNumber += 1
            folderUrl = folderUrl.deletingLastPathComponent().appendingPathComponent("\(folderName)\(fileNumber)")
        }

        // Create the folder
        do {
            try CEWorkspaceFile.fileManger.createDirectory(
                at: folderUrl,
                withIntermediateDirectories: true,
                attributes: [:]
            )
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    /// This function allows creating files in the selected folder or project main directory
    /// - Parameter fileName: The name of the new file
    func addFile(fileName: String) {
        // check the folder for other files, and see what the most common file extension is
        var fileExtensions: [String: Int] = ["": 0]

        for child in (self.isFolder ?
                      self.flattenedSiblings(withHeight: 2, ignoringFolders: true) :
                      parent?.flattenedSiblings(withHeight: 2, ignoringFolders: true)) ?? [] where !child.isFolder {
            // if the file extension was present before, add it now
            let childFileName = child.fileName(typeHidden: false)
            if let index = childFileName.lastIndex(of: ".") {
                let childFileExtension = ".\(childFileName.suffix(from: index).dropFirst())"
                fileExtensions[childFileExtension] = (fileExtensions[childFileExtension] ?? 0) + 1
            } else {
                fileExtensions[""] = (fileExtensions[""] ?? 0) + 1
            }
        }

        var largestValue = 0
        var idealExtension = ""
        for (extName, count) in fileExtensions where count > largestValue {
            idealExtension = extName
            largestValue = count
        }

        var fileUrl = nearestFolder.appendingPathComponent("\(fileName)\(idealExtension)")
        // If a file/folder with the same name exists, add a number to the end.
        var fileNumber = 0
        while CEWorkspaceFile.fileManger.fileExists(atPath: fileUrl.path) {
            fileNumber += 1
            fileUrl = fileUrl.deletingLastPathComponent()
                .appendingPathComponent("\(fileName)\(fileNumber)\(idealExtension)")
        }

        // Create the file
        CEWorkspaceFile.fileManger.createFile(
            atPath: fileUrl.path,
            contents: nil,
            attributes: [FileAttributeKey.creationDate: Date()]
        )
    }

    /// Nearest folder refers to the parent directory if this is a non-folder item, or itself if the item is a folder.
    var nearestFolder: URL {
        (self.isFolder ?
                    self.url :
                    self.url.deletingLastPathComponent())
    }

    /// This function deletes the item or folder from the current project
    func delete() {
        // This function also has to account for how the
        // - file system can change outside of the editor
        let deleteConfirmation = NSAlert()
        let message: String
        if self.isFolder || (self.children?.isEmpty ?? false) { // if its a file or an empty folder, call it by its name
            message = String(describing: self.fileName)
        } else {
            message = "the \((self.children?.count ?? 0) + 1) selected items"
        }
        deleteConfirmation.messageText = "Do you want to move \(message) to the Trash?"
        deleteConfirmation.informativeText = "This operation cannot be undone"
        deleteConfirmation.alertStyle = .critical
        deleteConfirmation.addButton(withTitle: "Move to Trash")
        deleteConfirmation.buttons.last?.hasDestructiveAction = true
        deleteConfirmation.addButton(withTitle: "Cancel")
        if deleteConfirmation.runModal() == .alertFirstButtonReturn { // "Delete" button
            if CEWorkspaceFile.fileManger.fileExists(atPath: self.url.path) {
                do {
                    try CEWorkspaceFile.fileManger.removeItem(at: self.url)
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }

    /// This function duplicates the item or folder
    func duplicate() {
        // If a file/folder with the same name exists, add "copy" to the end
        var fileUrl = self.url
        while CEWorkspaceFile.fileManger.fileExists(atPath: fileUrl.path) {
            let previousName = fileUrl.lastPathComponent
            let fileExtension = fileUrl.pathExtension.isEmpty ? "" : ".\(fileUrl.pathExtension)"
            let fileName = fileExtension.isEmpty ? previousName :
                previousName.replacingOccurrences(of: ".\(fileExtension)", with: "")
            fileUrl = fileUrl.deletingLastPathComponent().appendingPathComponent("\(fileName) copy\(fileExtension)")
        }

        if CEWorkspaceFile.fileManger.fileExists(atPath: self.url.path) {
            do {
                try CEWorkspaceFile.fileManger.copyItem(at: self.url, to: fileUrl)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

    /// This function moves the item or folder if possible
    func move(to newLocation: URL) {
        guard !CEWorkspaceFile.fileManger.fileExists(atPath: newLocation.path) else { return }
        createMissingParentDirectory(for: newLocation.deletingLastPathComponent())

        do {
            try CEWorkspaceFile.fileManger.moveItem(at: self.url, to: newLocation)
        } catch { fatalError(error.localizedDescription) }

        // This function recursively creates missing directories if the file is moved to a directory that does not exist
        func createMissingParentDirectory(for url: URL, createSelf: Bool = true) {
            // if the folder's parent folder doesn't exist, create it.
            if !CEWorkspaceFile.fileManger.fileExists(atPath: url.deletingLastPathComponent().path) {
                createMissingParentDirectory(for: url.deletingLastPathComponent())
            }
            // if the folder doesn't exist and the function was ordered to create it, create it.
            if createSelf && !CEWorkspaceFile.fileManger.fileExists(atPath: url.path) {
                // Create the folder
                do {
                    try CEWorkspaceFile.fileManger.createDirectory(
                        at: url,
                        withIntermediateDirectories: true,
                        attributes: [:]
                    )
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }

    // MARK: Comparable

    static func == (lhs: CEWorkspaceFile, rhs: CEWorkspaceFile) -> Bool {
        lhs.id == rhs.id
    }

    static func < (lhs: CEWorkspaceFile, rhs: CEWorkspaceFile) -> Bool {
        lhs.url.lastPathComponent < rhs.url.lastPathComponent
    }

    // MARK: Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(fileIdentifier)
        hasher.combine(id)
    }

}

extension Array where Element == CEWorkspaceFile {
    func find(by tabID: TabBarItemID) -> CEWorkspaceFile? {
        guard let item = first(where: { $0.tabID == tabID }) else {
            for element in self {
                if let item = element.children?.find(by: tabID) {
                    return item
                }
            }
            return nil
        }
        return item
    }
}
