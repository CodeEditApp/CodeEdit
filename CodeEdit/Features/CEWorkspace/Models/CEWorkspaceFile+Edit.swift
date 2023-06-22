//
//  CEWorkspaceFileManager+Edit.swift
//  CodeEdit
//
//  Created by Axel Martinez on 21/5/23.
//

import Foundation
import SwiftUI

extension CEWorkspaceFile {
    /// This function allows creation of folders in the main directory or sub-folders
    /// - Parameter folderName: The name of the new folder
    func addFolder(folderName: String) {
        // Check if folder, if it is create folder under self, else create on same level.
        var folderUrl = (self.isFolder ?
                         self.url.appendingPathComponent(folderName) :
                            self.url.deletingLastPathComponent().appendingPathComponent(folderName))

        // If a file/folder with the same name exists, add a number to the end.
        var fileNumber = 0
        while CEWorkspaceFile.fileManager.fileExists(atPath: folderUrl.path) {
            fileNumber += 1
            folderUrl = folderUrl.deletingLastPathComponent().appendingPathComponent("\(folderName)\(fileNumber)")
        }

        // Create the folder
        do {
            try CEWorkspaceFile.fileManager.createDirectory(
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
        while CEWorkspaceFile.fileManager.fileExists(atPath: fileUrl.path) {
            fileNumber += 1
            fileUrl = fileUrl.deletingLastPathComponent()
                .appendingPathComponent("\(fileName)\(fileNumber)\(idealExtension)")
        }

        // Create the file
        CEWorkspaceFile.fileManager.createFile(
            atPath: fileUrl.path,
            contents: nil,
            attributes: [FileAttributeKey.creationDate: Date()]
        )
    }

    /// This function deletes the item or folder from the current project
    /// - Parameter file: The file to remove
    func delete() {
        if self.parent != nil {
            // This function also has to account for how the
            // - file system can change outside of the editor
            let deleteConfirmation = NSAlert()
            let message: String

            // if its a file or an empty folder, call it by its name
            if self.isFolder || (self.children?.isEmpty ?? false) {
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
                if CEWorkspaceFile.fileManager.fileExists(atPath: self.url.path) {
                    do {
                        try CEWorkspaceFile.fileManager.removeItem(at: self.url)
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }
    }

    /// This function duplicates the item or folder
    func duplicate() {
        // If a file/folder with the same name exists, add "copy" to the end
        var fileUrl = self.url
        while CEWorkspaceFile.fileManager.fileExists(atPath: fileUrl.path) {
            let previousName = fileUrl.lastPathComponent
            let fileExtension = fileUrl.pathExtension.isEmpty ? "" : ".\(fileUrl.pathExtension)"
            let fileName = fileExtension.isEmpty ? previousName :
                previousName.replacingOccurrences(of: ".\(fileExtension)", with: "")
            fileUrl = fileUrl.deletingLastPathComponent().appendingPathComponent("\(fileName) copy\(fileExtension)")
        }

        if CEWorkspaceFile.fileManager.fileExists(atPath: self.url.path) {
            do {
                try CEWorkspaceFile.fileManager.copyItem(at: self.url, to: fileUrl)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

    /// This function moves the item or folder if possible
    /// - Parameter file: The file to be moved
    /// - Parameter to: The location where the files is going to be moved
    func move(to newLocation: URL) {
        guard !CEWorkspaceFile.fileManager.fileExists(atPath: newLocation.path) else { return }
        createMissingParentDirectory(for: newLocation.deletingLastPathComponent())

        do {
            try CEWorkspaceFile.fileManager.moveItem(at: self.url, to: newLocation)
        } catch { fatalError(error.localizedDescription) }

        // This function recursively creates missing directories if the file is moved to a directory that does not exist
        func createMissingParentDirectory(for url: URL, createSelf: Bool = true) {
            // if the folder's parent folder doesn't exist, create it.
            if !CEWorkspaceFile.fileManager.fileExists(atPath: url.deletingLastPathComponent().path) {
                createMissingParentDirectory(for: url.deletingLastPathComponent())
            }
            // if the folder doesn't exist and the function was ordered to create it, create it.
            if createSelf && !CEWorkspaceFile.fileManager.fileExists(atPath: url.path) {
                // Create the folder
                do {
                    try CEWorkspaceFile.fileManager.createDirectory(
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
}
