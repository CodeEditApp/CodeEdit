//
//  CEWorkspaceFileManager+FileSystem.swift
//  CodeEdit
//
//  Created by Khan Winter on 9/30/23.
//

import Foundation
import AppKit

extension CEWorkspaceFileManager {
    /// This function allows creation of folders in the main directory or sub-folders
    /// - Parameters:
    ///   - folderName: The name of the new folder
    ///   - file: The file to add the new folder to.
    /// - Returns: The ``CEWorkspaceFile`` representing the folder in the file manager's cache.
    /// - Authors: Mattijs Eikelenboom, KaiTheRedNinja. *Moved from 7c27b1e*
    func addFolder(folderName: String, toFile file: CEWorkspaceFile) throws -> CEWorkspaceFile {
        // Check if folder, if it is create folder under self, else create on same level.
        var folderUrl = (
            file.isFolder ? file.url.appending(path: folderName)
            : file.url.deletingLastPathComponent().appending(path: folderName)
        )

        // If a file/folder with the same name exists, add a number to the end.
        var fileNumber = 0
        while fileManager.fileExists(atPath: folderUrl.path) {
            fileNumber += 1
            folderUrl = folderUrl.deletingLastPathComponent().appending(path: "\(folderName)\(fileNumber)")
        }

        // Create the folder
        do {
            try fileManager.createDirectory(
                at: folderUrl,
                withIntermediateDirectories: true,
                attributes: [:]
            )

            try rebuildFiles(fromItem: file.isFolder ? file : file.parent ?? file)
            notifyObservers(updatedItems: [file.isFolder ? file : file.parent ?? file])

            guard let newFolder = getFile(folderUrl.path(), createIfNotFound: true) else {
                throw FileManagerError.fileNotFound
            }
            return newFolder
        } catch {
            logger.error("Failed to create folder: \(error, privacy: .auto)")
            throw error
        }
    }

    /// This function allows creating files in the selected folder or project main directory
    /// - Parameters:
    ///   - fileName: The name of the new file
    ///   - file: The file to add the new file to.
    ///   - useExtension: The file extension to use. Leave `nil` to guess using relevant nearby files.
    /// - Authors: Mattijs Eikelenboom, KaiTheRedNinja. *Moved from 7c27b1e*
    /// - Throws: Throws a `CocoaError.fileWriteUnknown` with the file url if creating the file fails, and calls
    ///           ``rebuildFiles(fromItem:deep:)`` which throws other `FileManager` errors.
    /// - Returns: The ``CEWorkspaceFile`` representing the new file in the file manager's cache.
    func addFile(
        fileName: String,
        toFile file: CEWorkspaceFile,
        useExtension: String? = nil,
        contents: Data? = nil
    ) throws -> CEWorkspaceFile {
        // check the folder for other files, and see what the most common file extension is
        do {
            var fileExtension: String
            if fileName.contains(".") {
                // If we already have a file extension in the name, don't add another one
                fileExtension = ""
            } else {
                fileExtension = useExtension ?? findCommonFileExtension(for: file)

                // Don't add a . if the extension is empty, but add it if it's missing.
                if !fileExtension.isEmpty && !fileExtension.starts(with: ".") {
                    fileExtension = "." + fileExtension
                }
            }

            var fileUrl = file.nearestFolder.appending(path: "\(fileName)\(fileExtension)")
            // If a file/folder with the same name exists, add a number to the end.
            var fileNumber = 0
            while fileManager.fileExists(atPath: fileUrl.path) {
                fileNumber += 1
                fileUrl = fileUrl.deletingLastPathComponent()
                    .appending(path: "\(fileName)\(fileNumber)\(fileExtension)")
            }

            guard fileUrl.fileName.isValidFilename else {
                throw FileManagerError.invalidFileName
            }

            // Create the file
            guard fileManager.createFile(
                atPath: fileUrl.path,
                contents: contents,
                attributes: [FileAttributeKey.creationDate: Date()]
            ) else {
                throw CocoaError.error(.fileWriteUnknown, url: fileUrl)
            }

            try rebuildFiles(fromItem: file.isFolder ? file : file.parent ?? file)
            notifyObservers(updatedItems: [file.isFolder ? file : file.parent ?? file])

            // Create if not found here because this should be indexed if we're creating it.
            // It's not often a user makes a file and then doesn't use it.
            guard let newFile = getFile(fileUrl.path, createIfNotFound: true) else {
                throw FileManagerError.fileNotIndexed
            }
            return newFile
        } catch {
            logger.error("Failed to add file: \(error, privacy: .auto)")
            throw error
        }
    }

    /// Finds a common file extension in the same directory as a file. Defaults to `txt` if no better alternatives
    /// are found.
    /// - Parameter file: The file to use to determine a common extension.
    /// - Returns: The suggested file extension.
    private func findCommonFileExtension(for file: CEWorkspaceFile) -> String {
        var fileExtensions: [String: Int] = ["": 0]

        for child in (
            file.isFolder ? file.flattenedSiblings(withHeight: 2, ignoringFolders: true, using: self)
            : file.parent?.flattenedSiblings(withHeight: 2, ignoringFolders: true, using: self)
        ) ?? []
        where !child.isFolder {
            // if the file extension was present before, add it now
            let childFileName = child.fileName(typeHidden: false)
            if let index = childFileName.lastIndex(of: ".") {
                let childFileExtension = ".\(childFileName.suffix(from: index).dropFirst())"
                fileExtensions[childFileExtension] = (fileExtensions[childFileExtension] ?? 0) + 1
            } else {
                fileExtensions[""] = (fileExtensions[""] ?? 0) + 1
            }
        }

        return fileExtensions.max(by: { $0.value < $1.value })?.key ?? "txt"
    }

    /// This function deletes the item or folder from the current project by moving to Trash
    /// - Parameters:
    ///   - file: The file or folder to delete
    /// - Authors: Paul Ebose
    public func trash(file: CEWorkspaceFile) throws {
        do {
            guard fileManager.fileExists(atPath: file.url.path) else {
                throw FileManagerError.fileNotFound
            }
            try fileManager.trashItem(at: file.url, resultingItemURL: nil)
        } catch {
            logger.error("Failed to trash file: \(error, privacy: .auto)")
            throw error
        }
    }

    /// This function deletes the item or folder from the current project by erasing immediately.
    /// - Parameters:
    ///   - file: The file to delete
    ///   - confirmDelete: True to present an alert to confirm the delete.
    /// - Authors: Mattijs Eikelenboom, KaiTheRedNinja., Paul Ebose *Moved from 7c27b1e*
    public func delete(file: CEWorkspaceFile, confirmDelete: Bool = true) throws {
        // This function also has to account for how the
        // - file system can change outside of the editor
        let fileName = file.name

        let deleteConfirmation = NSAlert()
        deleteConfirmation.messageText = "Do you want to delete “\(fileName)”?"
        deleteConfirmation.informativeText = "This item will be deleted immediately. You can't undo this action."
        deleteConfirmation.alertStyle = .critical
        deleteConfirmation.addButton(withTitle: "Delete")
        deleteConfirmation.buttons.last?.hasDestructiveAction = true
        deleteConfirmation.addButton(withTitle: "Cancel")
        if !confirmDelete || deleteConfirmation.runModal() == .alertFirstButtonReturn { // "Delete" button
            if fileManager.fileExists(atPath: file.url.path) {
                try deleteFile(at: file.url)
            }
        }
    }

    /// This function deletes multiple files or folders from the current project by erasing immediately.
    /// - Parameters:
    ///   - files: The files to delete
    ///   - confirmDelete: True to present an alert to confirm the delete.
    public func batchDelete(files: Set<CEWorkspaceFile>, confirmDelete: Bool = true) throws {
        let deleteConfirmation = NSAlert()
        deleteConfirmation.messageText = "Are you sure you want to delete the \(files.count) selected items?"
        // swiftlint:disable:next line_length
        deleteConfirmation.informativeText = "\(files.count) items will be deleted immediately. You cannot undo this action."
        deleteConfirmation.alertStyle = .critical
        deleteConfirmation.addButton(withTitle: "Delete")
        deleteConfirmation.buttons.last?.hasDestructiveAction = true
        deleteConfirmation.addButton(withTitle: "Cancel")
        if !confirmDelete || deleteConfirmation.runModal() == .alertFirstButtonReturn {
            for file in files where fileManager.fileExists(atPath: file.url.path) {
                try deleteFile(at: file.url)
            }
        }
    }

    /// Delete a file from the file system.
    /// - Note: Use ``trash(file:)`` if the file should be moved to the trash. This is irreversible.
    /// - Parameter url: The file URL to delete.
    private func deleteFile(at url: URL) throws {
        do {
            guard fileManager.fileExists(atPath: url.path) else {
                throw FileManagerError.fileNotFound
            }
            try fileManager.removeItem(at: url)
        } catch {
            logger.error("Failed to delete file: \(error, privacy: .auto)")
            throw error
        }
    }

    /// This function duplicates the item or folder
    /// - Parameter file: The file to duplicate
    /// - Authors: Mattijs Eikelenboom, KaiTheRedNinja. *Moved from 7c27b1e*
    public func duplicate(file: CEWorkspaceFile) throws {
        // If a file/folder with the same name exists, add "copy" to the end
        var fileUrl = file.url
        while fileManager.fileExists(atPath: fileUrl.path) {
            let previousName = fileUrl.lastPathComponent
            let fileExtension = fileUrl.pathExtension.isEmpty ? "" : ".\(fileUrl.pathExtension)"
            let fileName = fileExtension.isEmpty ? previousName :
            previousName.replacingOccurrences(of: fileExtension, with: "")
            fileUrl = fileUrl.deletingLastPathComponent().appending(path: "\(fileName) copy\(fileExtension)")
        }

        if fileManager.fileExists(atPath: file.url.path) {
            do {
                try fileManager.copyItem(at: file.url, to: fileUrl)
            } catch {
                logger.error("Failed to duplicate file: \(error, privacy: .auto)")
                throw error
            }
        }
    }

    /// This function moves the item or folder if possible
    /// - Parameters:
    ///   - file: The file to move.
    ///   - newLocation: The destination to move the file to.
    /// - Authors: Mattijs Eikelenboom, KaiTheRedNinja. *Moved from 7c27b1e*
    /// - Returns: The new file object, if it has been indexed. The file manager does not index folders that have not
    ///            been revealed to save memory. This may move a file deeper into the tree than is indexed. In that
    ///            case, it is correct to return nothing. This is intentionally different than `addFile`.
    @discardableResult
    public func move(file: CEWorkspaceFile, to newLocation: URL) throws -> CEWorkspaceFile? {
        do {
            guard fileManager.fileExists(atPath: file.url.path()) else {
                throw FileManagerError.originFileNotFound
            }

            guard !fileManager.fileExists(atPath: newLocation.path) else {
                throw FileManagerError.destinationFileExists
            }

            try createMissingParentDirectory(for: newLocation.deletingLastPathComponent())

            try fileManager.moveItem(at: file.url, to: newLocation)

            // This function recursively creates missing directories if the file is moved to a directory that does
            // not exist
            func createMissingParentDirectory(for url: URL, createSelf: Bool = true) throws {
                // if the folder's parent folder doesn't exist, create it.
                if !fileManager.fileExists(atPath: url.deletingLastPathComponent().path) {
                    try createMissingParentDirectory(for: url.deletingLastPathComponent())
                }
                // if the folder doesn't exist and the function was ordered to create it, create it.
                if createSelf && !fileManager.fileExists(atPath: url.path) {
                    // Create the folder
                    try fileManager.createDirectory(
                        at: url,
                        withIntermediateDirectories: true,
                        attributes: [:]
                    )
                }
            }

            if let parent = file.parent {
                try rebuildFiles(fromItem: parent)
                notifyObservers(updatedItems: [parent])
            }

            // If we have the new parent file, let's rebuild that directory too
            if let newFileParent = getFile(newLocation.deletingLastPathComponent().path) {
                try rebuildFiles(fromItem: newFileParent)
                notifyObservers(updatedItems: [newFileParent])
            }

            return getFile(newLocation.absoluteURL.path)
        } catch {
            logger.error("Failed to move file: \(error, privacy: .auto)")
            throw error
        }
    }

    /// Copy a file's contents to a new location.
    /// - Parameters:
    ///   - file: The file to copy.
    ///   - newLocation: The location to copy to.
    public func copy(file: CEWorkspaceFile, to newLocation: URL) throws {
        do {
            guard file.url != newLocation && !fileManager.fileExists(atPath: newLocation.absoluteString) else {
                throw FileManagerError.originFileNotFound
            }
            try fileManager.copyItem(at: file.url, to: newLocation)
        } catch {
            logger.error("Failed to copy file: \(error, privacy: .auto)")
            throw error
        }
    }
}
