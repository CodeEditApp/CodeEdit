//
//  FileSystemClient.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 04/02/2023.
//

import Combine
import Foundation

protocol CEWorkspaceFileManagerObserver: AnyObject {
    func fileManagerUpdated()
}

/// This class is used to load the files of the machine into a CodeEdit workspace.
final class CEWorkspaceFileManager {
    private(set) var fileManager = FileManager.default
    private(set) var ignoredFilesAndFolders: Set<String>
    private(set) var flattenedFileItems: [String: CEWorkspaceFile]
    private var fsEventStream: DirectoryEventStream?

    private var observers: NSHashTable<AnyObject>

    let folderUrl: URL
    let workspaceItem: CEWorkspaceFile

    init(folderUrl: URL, ignoredFilesAndFolders: Set<String>) {
        self.observers = NSHashTable<AnyObject>.weakObjects()

        self.folderUrl = folderUrl
        self.ignoredFilesAndFolders = ignoredFilesAndFolders

        self.workspaceItem = CEWorkspaceFile(url: folderUrl, children: [])
        self.flattenedFileItems = [workspaceItem.id: workspaceItem]

        self.setup()
    }

    private func setup() {
        // initial load, get all files & directories under workspace URL
        var workspaceFiles: [CEWorkspaceFile]
        do {
            workspaceFiles = try loadFiles(fromUrl: self.folderUrl)
        } catch {
            fatalError("Failed to loadFiles")
        }

        fsEventStream = DirectoryEventStream(directory: self.folderUrl.path) { [weak self] path, event, deepRebuild in
            self?.fileSystemEventReceived(directory: path, event: event, deepRebuild: deepRebuild)
        }

        // Root workspace fileItem
        let workspaceFile = CEWorkspaceFile(url: self.folderUrl, children: workspaceFiles.sortItems(foldersOnTop: true))
        flattenedFileItems[workspaceFile.id] = workspaceFile
        workspaceFiles.forEach { item in
            item.parent = workspaceFile
        }
    }

    /// Recursive loading of files into `FileItem`s
    /// - Parameter url: The URL of the directory to load the items of
    /// - Returns: `[FileItem]` representing the contents of the directory
    private func loadFiles(fromUrl url: URL) throws -> [CEWorkspaceFile] {
        let directoryContents = try fileManager.contentsOfDirectory(
            at: url.resolvingSymlinksInPath(),
            includingPropertiesForKeys: nil
        )
        var items: [CEWorkspaceFile] = []

        for itemURL in directoryContents {
            guard !ignoredFilesAndFolders.contains(itemURL.lastPathComponent) else { continue }

            var isDir: ObjCBool = false

            if fileManager.fileExists(atPath: itemURL.path, isDirectory: &isDir) {
                var subItems: [CEWorkspaceFile]?

                if isDir.boolValue {
                    // Recursively fetch subdirectories and files if the path points to a directory
                    subItems = try loadFiles(fromUrl: itemURL)
                }

                let newFileItem = CEWorkspaceFile(
                    url: itemURL,
                    children: subItems?.sortItems(foldersOnTop: true)
                )

                subItems?.forEach { $0.parent = newFileItem }
                items.append(newFileItem)
                flattenedFileItems[newFileItem.id] = newFileItem
            }
        }

        return items
    }

    /// A function that, given a file's path, returns a `FileItem` if it exists
    /// within the scope of the `FileSystemClient`.
    /// - Parameter path: The file's full path
    /// - Returns: The file item corresponding to the file
    func getFile(_ path: String) -> CEWorkspaceFile? {
        flattenedFileItems[path]
    }

    /// Usually run when the owner of the `FileSystemClient` doesn't need it anymore.
    /// This de-inits most functions in the `FileSystemClient`, so that in case it isn't de-init'd it does not use up
    /// significant amounts of RAM.
    func cleanUp() {
        fsEventStream?.cancel()
        workspaceItem.children = []
        flattenedFileItems = [workspaceItem.id: workspaceItem]
    }

    /// Called by `fsEventStream` when an event occurs.
    ///
    /// This method may be called on a background thread, but all work done by this function will be queued on the main
    /// thread.
    /// - Parameters:
    ///   - directory: The directory where the event occurred.
    ///   - event: The event that occurred.
    ///   - deepRebuild: Whether or not the directory needs to be recursively rebuilt.
    private func fileSystemEventReceived(directory: String, event: FSEvent, deepRebuild: Bool) {
        DispatchQueue.main.async {
            var directory = directory
            if directory.last == "/" {
                directory.removeLast()
            }
            guard let item = self.getFile(directory) else {
                return
            }
            try? self.rebuildFiles(fromItem: item)
            self.notifyObservers()
        }
    }

    /// Similar to `loadFiles`, but creates or deletes children of the
    /// `FileItem` so that they are accurate with the file system, instead of creating an
    /// entirely new `FileItem`. Can optionally run a deep rebuild.
    /// - Parameters:
    ///   - fileItem: The `FileItem` to correct the children of
    ///   - deep: Set to `true` if this should perform the rebuild recursively.
    func rebuildFiles(fromItem fileItem: CEWorkspaceFile, deep: Bool = false) throws {
        // get the actual directory children
        let directoryContentsUrls = try fileManager.contentsOfDirectory(
            at: fileItem.url.resolvingSymlinksInPath(),
            includingPropertiesForKeys: nil
        )

        // test for deleted children, and remove them from the index
        for oldContent in fileItem.children ?? [] where !directoryContentsUrls.contains(oldContent.url) {
            if let removeAt = fileItem.children?.firstIndex(of: oldContent) {
                fileItem.children?.remove(at: removeAt)
                flattenedFileItems.removeValue(forKey: oldContent.id)
            }
        }

        // test for new children, and index them using loadFiles
        for newContent in directoryContentsUrls {
            guard !ignoredFilesAndFolders.contains(newContent.lastPathComponent) else { continue }

            // if the child has already been indexed, continue to the next item.
            guard !(fileItem.children?.map({ $0.url }).contains(newContent) ?? false) else { continue }

            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: newContent.path, isDirectory: &isDir) {
                var subItems: [CEWorkspaceFile]?

                if isDir.boolValue { subItems = try loadFiles(fromUrl: newContent) }

                let newFileItem = CEWorkspaceFile(
                    url: newContent,
                    children: subItems?.sortItems(foldersOnTop: true)
                )

                subItems?.forEach { $0.parent = newFileItem }

                newFileItem.parent = fileItem
                flattenedFileItems[newFileItem.id] = newFileItem
                fileItem.children?.append(newFileItem)
            }
        }

        fileItem.children = fileItem.children?.sortItems(foldersOnTop: true)
        fileItem.children?.forEach({
            if deep && $0.isFolder {
                try? rebuildFiles(fromItem: $0, deep: deep)
            }
            flattenedFileItems[$0.id] = $0
        })
    }

    func notifyObservers() {
        observers.allObjects.reversed().forEach { delegate in
            guard let delegate = delegate as? CEWorkspaceFileManagerObserver else {
                observers.remove(delegate)
                return
            }
            delegate.fileManagerUpdated()
        }
    }

    func addObserver(_ observer: CEWorkspaceFileManagerObserver) {
        observers.add(observer as AnyObject)
    }

    func removeObserver(_ observer: CEWorkspaceFileManagerObserver) {
        observers.remove(observer as AnyObject)
    }

    deinit {
        observers.removeAllObjects()
    }
}
