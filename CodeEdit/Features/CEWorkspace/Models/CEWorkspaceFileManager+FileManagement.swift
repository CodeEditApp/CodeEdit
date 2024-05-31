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
    /// - Authors: Mattijs Eikelenboom, KaiTheRedNinja. *Moved from 7c27b1e*
    func addFolder(folderName: String, toFile file: CEWorkspaceFile) {
        // Check if folder, if it is create folder under self, else create on same level.
        var folderUrl = (
            file.isFolder ? file.url.appendingPathComponent(folderName)
            : file.url.deletingLastPathComponent().appendingPathComponent(folderName)
        )

        // If a file/folder with the same name exists, add a number to the end.
        var fileNumber = 0
        while fileManager.fileExists(atPath: folderUrl.path) {
            fileNumber += 1
            folderUrl = folderUrl.deletingLastPathComponent().appendingPathComponent("\(folderName)\(fileNumber)")
        }

        // Create the folder
        do {
            try fileManager.createDirectory(
                at: folderUrl,
                withIntermediateDirectories: true,
                attributes: [:]
            )
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    /// This function allows creating files in the selected folder or project main directory
    /// - Parameters:
    ///   - fileName: The name of the new file
    ///   - file: The file to add the new file to.
    /// - Authors: Mattijs Eikelenboom, KaiTheRedNinja. *Moved from 7c27b1e*
    func addFile(fileName: String, toFile file: CEWorkspaceFile) {
        // check the folder for other files, and see what the most common file extension is
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

        var largestValue = 0
        var idealExtension = ""
        for (extName, count) in fileExtensions where count > largestValue {
            idealExtension = extName
            largestValue = count
        }

        var fileUrl = file.nearestFolder.appendingPathComponent("\(fileName)\(idealExtension)")
        // If a file/folder with the same name exists, add a number to the end.
        var fileNumber = 0
        while fileManager.fileExists(atPath: fileUrl.path) {
            fileNumber += 1
            fileUrl = fileUrl.deletingLastPathComponent()
                .appendingPathComponent("\(fileName)\(fileNumber)\(idealExtension)")
        }

        // Create the file
        fileManager.createFile(
            atPath: fileUrl.path,
            contents: nil,
            attributes: [FileAttributeKey.creationDate: Date()]
        )
    }

    /// This function deletes the item or folder from the current project by moving to Trash
    /// - Parameters:
    ///   - file: The file or folder to delete
    /// - Authors: Paul Ebose
    public func trash(file: CEWorkspaceFile) {
        if fileManager.fileExists(atPath: file.url.path) {
            do {
                try fileManager.trashItem(at: file.url, resultingItemURL: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    /// This function deletes the item or folder from the current project by erasing immediately.
    /// - Parameters:
    ///   - file: The file to delete
    ///   - confirmDelete: True to present an alert to confirm the delete.
    /// - Authors: Mattijs Eikelenboom, KaiTheRedNinja., Paul Ebose *Moved from 7c27b1e*
    public func delete(file: CEWorkspaceFile, confirmDelete: Bool = true) {
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
                do {
                    try fileManager.removeItem(at: file.url)
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }

    /// This function duplicates the item or folder
    /// - Parameter file: The file to duplicate
    /// - Authors: Mattijs Eikelenboom, KaiTheRedNinja. *Moved from 7c27b1e*
    public func duplicate(file: CEWorkspaceFile) {
        // If a file/folder with the same name exists, add "copy" to the end
        var fileUrl = file.url
        while fileManager.fileExists(atPath: fileUrl.path) {
            let previousName = fileUrl.lastPathComponent
            let fileExtension = fileUrl.pathExtension.isEmpty ? "" : ".\(fileUrl.pathExtension)"
            let fileName = fileExtension.isEmpty ? previousName :
            previousName.replacingOccurrences(of: fileExtension, with: "")
            fileUrl = fileUrl.deletingLastPathComponent().appendingPathComponent("\(fileName) copy\(fileExtension)")
        }

        if fileManager.fileExists(atPath: file.url.path) {
            do {
                try fileManager.copyItem(at: file.url, to: fileUrl)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

    /// This function moves the item or folder if possible
    /// - Parameters:
    ///   - file: The file to move.
    ///   - newLocation: The destination to move the file to.
    /// - Authors: Mattijs Eikelenboom, KaiTheRedNinja. *Moved from 7c27b1e*
    public func move(file: CEWorkspaceFile, to newLocation: URL) {
        guard !fileManager.fileExists(atPath: newLocation.path) else { return }
        createMissingParentDirectory(for: newLocation.deletingLastPathComponent())

        do {
            try fileManager.moveItem(at: file.url, to: newLocation)
        } catch { fatalError(error.localizedDescription) }

        // This function recursively creates missing directories if the file is moved to a directory that does not exist
        func createMissingParentDirectory(for url: URL, createSelf: Bool = true) {
            // if the folder's parent folder doesn't exist, create it.
            if !fileManager.fileExists(atPath: url.deletingLastPathComponent().path) {
                createMissingParentDirectory(for: url.deletingLastPathComponent())
            }
            // if the folder doesn't exist and the function was ordered to create it, create it.
            if createSelf && !fileManager.fileExists(atPath: url.path) {
                // Create the folder
                do {
                    try fileManager.createDirectory(
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

    /// Copy a file's contents to a new location.
    /// - Parameters:
    ///   - file: The file to copy.
    ///   - newLocation: The location to copy to.
    public func copy(file: CEWorkspaceFile, to newLocation: URL) {
        guard file.url != newLocation && !fileManager.fileExists(atPath: newLocation.absoluteString) else { return }
        do {
            try fileManager.copyItem(at: file.url, to: newLocation)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
