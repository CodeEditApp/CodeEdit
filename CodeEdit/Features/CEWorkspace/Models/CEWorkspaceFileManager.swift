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
    /// Maps all directories to it's children's paths.
    private var childrenMap: [String: [String]] = [:]
    private var fsEventStream: DirectoryEventStream?

    private var observers: NSHashTable<AnyObject>

    let folderUrl: URL
    let workspaceItem: CEWorkspaceFile

    init(folderUrl: URL, ignoredFilesAndFolders: Set<String>) {
        self.observers = NSHashTable<AnyObject>.weakObjects()

        self.folderUrl = folderUrl
        self.ignoredFilesAndFolders = ignoredFilesAndFolders

        self.workspaceItem = CEWorkspaceFile(url: folderUrl)
        self.flattenedFileItems = [workspaceItem.id: workspaceItem]

        fsEventStream = DirectoryEventStream(directory: self.folderUrl.path) { [weak self] path, event, deepRebuild in
            self?.fileSystemEventReceived(directory: path, event: event, deepRebuild: deepRebuild)
        }
    }

    // MARK: - Public API

    /// A function that, given a file's path, returns a `FileItem` if it exists
    /// within the scope of the `FileSystemClient`.
    /// - Parameters:
    ///   - path: The file's relative path.
    ///   - createIfNotFound: Set to true if the function should index any intermediate directories to find the file,
    ///                       as well as index the file if it is not already.
    /// - Returns: The file item corresponding to the file
    func getFile(
        _ path: String,
        createIfNotFound: Bool = false
    ) -> CEWorkspaceFile? {
        if let file = flattenedFileItems[path] {
            return file
        } else if createIfNotFound {
            let url = URL(fileURLWithPath: path, relativeTo: folderUrl)

            // Drill down towards the file, indexing any directories needed. If file is not in the `folderURL` or
            // subdirectories, exit.
            guard url.absoluteString.starts(with: folderUrl.absoluteString),
                  url.pathComponents.count > folderUrl.pathComponents.count else {
                return nil
            }
            let pathComponents = url.pathComponents.dropFirst(folderUrl.pathComponents.count)
            var currentURL = folderUrl

            for component in pathComponents {
                currentURL.append(component: component)

                if let file = flattenedFileItems[currentURL.relativePath], childrenMap[file.id] == nil {
                    loadChildrenForFile(file)
                }
            }

            return flattenedFileItems[url.relativePath]
        }

        return nil
    }

    func childrenOfFile(_ file: CEWorkspaceFile) -> [CEWorkspaceFile]? {
        if file.isFolder {
            if childrenMap[file.id] == nil {
                // Load the children
                loadChildrenForFile(file)
            }

            return childrenMap[file.id]?.compactMap { flattenedFileItems[$0] }
        }
        return nil
    }

    private func loadChildrenForFile(_ file: CEWorkspaceFile) {
        guard let children = urlsForDirectory(file) else {
            return
        }
        for child in children {
            let newFileItem = CEWorkspaceFile(url: child)
            newFileItem.parent = file
            flattenedFileItems[newFileItem.id] = newFileItem
        }
        childrenMap[file.id] = children.map { $0.relativePath }
    }

    private func urlsForDirectory(_ file: CEWorkspaceFile) -> [URL]? {
        try? fileManager.contentsOfDirectory(
            at: file.url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.includesDirectoriesPostOrder, .skipsSubdirectoryDescendants]
        )
        .map { URL(filePath: $0.path(), relativeTo: folderUrl) }
        .sortItems(foldersOnTop: true)
    }

    // MARK: - Directory Events

    /// Usually run when the owner of the `FileSystemClient` doesn't need it anymore.
    /// This de-inits most functions in the `FileSystemClient`, so that in case it isn't de-init'd it does not use up
    /// significant amounts of RAM.
    func cleanUp() {
        fsEventStream?.cancel()
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
        // Do not index directories that are not already loaded.
        guard childrenMap[fileItem.id] != nil else { return }

        // get the actual directory children
        let directoryContentsUrls = try fileManager.contentsOfDirectory(
            at: fileItem.url.resolvingSymlinksInPath(),
            includingPropertiesForKeys: nil
        )

        // test for deleted children, and remove them from the index
        for (idx, oldURL) in (childrenMap[fileItem.id] ?? []).map({ URL(filePath: $0) }).enumerated().reversed()
        where !directoryContentsUrls.contains(oldURL) {
            flattenedFileItems.removeValue(forKey: oldURL.relativePath)
            childrenMap[fileItem.id]?.remove(at: idx)
        }

        // test for new children, and index them using loadFiles
        for newContent in directoryContentsUrls {
            // if the child has already been indexed, continue to the next item.
            guard !ignoredFilesAndFolders.contains(newContent.lastPathComponent) &&
                  !(childrenMap[fileItem.id]?.contains(newContent.relativePath) ?? true) else { continue }

            if fileManager.fileExists(atPath: newContent.path) {
                let newFileItem = CEWorkspaceFile(url: newContent)

                newFileItem.parent = fileItem
                flattenedFileItems[newFileItem.id] = newFileItem
                childrenMap[fileItem.id]?.append(newFileItem.id)
            }
        }

        childrenMap[fileItem.id] = childrenMap[fileItem.id]?
            .map { URL(filePath: $0) }
            .sortItems(foldersOnTop: true)
            .map { $0.relativePath }

        if deep && childrenMap[fileItem.id] != nil {
            for child in (childrenMap[fileItem.id] ?? []).compactMap({ flattenedFileItems[$0] }) {
                try? rebuildFiles(fromItem: child)
            }
        }
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
