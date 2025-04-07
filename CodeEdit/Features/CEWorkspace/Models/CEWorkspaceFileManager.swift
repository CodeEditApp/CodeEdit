//
//  FileSystemClient.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 04/02/2023.
//

import Combine
import Foundation
import AppKit
import OSLog

protocol CEWorkspaceFileManagerObserver: AnyObject {
    func fileManagerUpdated(updatedItems: Set<CEWorkspaceFile>)
}

/// This class is used to load, modify, and listen to files on a user's machine.
///
/// The workspace file manager provides an API for:
/// - Navigating and loading file items.
/// - Moving and modifying files.
/// - Listening for file system updates and notifying observers.
///
/// File caching in CodeEdit is done lazily. the ``CEWorkspaceFileManager`` will only create ``CEWorkspaceFile``s for
/// from files that are needed for some UI component, and ignores all other files. This is done primarily to prevent
/// CodeEdit from wasting resources finding and caching a potentially large file tree (eg, a user's home directory).
///
/// When the workspace is first loaded, the file manager will only load the contents of the workspace directory. To find
/// files after this, calls to ``CEWorkspaceFileManager/getFile(_:createIfNotFound:)`` or
/// ``CEWorkspaceFileManager/childrenOfFile(_:)`` can cause the children for a file to be loaded into CodeEdit's cache
/// of files.
///
/// Moving and modifying files is done via the methods: ``CEWorkspaceFileManager/addFile(fileName:toFile:)``,
/// ``CEWorkspaceFileManager/addFolder(folderName:toFile:)``, ``CEWorkspaceFileManager/delete(file:)``,
/// ``CEWorkspaceFileManager/copy(file:to:)``, and ``CEWorkspaceFileManager/duplicate(file:)``.
///
/// To listen for updates, the ``CEWorkspaceFileManager`` uses a ``DirectoryEventStream`` to listen to updates for any
/// files under the ``CEWorkspaceFileManager/folderUrl`` url. Those can be passed on to listeners that conform to the
/// ``CEWorkspaceFileManagerObserver`` protocol. Use the ``CEWorkspaceFileManager/addObserver(_:)``
/// and ``CEWorkspaceFileManager/removeObserver(_:)`` to add or remove observers. Observers are kept as weak references.
final class CEWorkspaceFileManager {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "CEWorkspaceFileManager")
    private(set) var fileManager: FileManager
    private(set) var ignoredFilesAndFolders: Set<String>

    var flattenedFileItems: [String: CEWorkspaceFile]
    /// Maps all directories to it's children's paths.
    var childrenMap: [String: [String]] = [:]
    var fsEventStream: DirectoryEventStream?
    var observers: NSHashTable<AnyObject> = .weakObjects()

    let folderUrl: URL
    let workspaceItem: CEWorkspaceFile
    weak var sourceControlManager: SourceControlManager?

    /// Create a file  manager object with a root and a set of files to ignore.
    /// - Parameters:
    ///   - folderUrl: The folder to use as the root of the file manager.
    ///   - ignoredFilesAndFolders: A set of files to ignore. These should not be paths, but rather file names
    ///                             like `.DS_Store`
    init(
        folderUrl: URL,
        ignoredFilesAndFolders: Set<String>,
        fileManager: FileManager = FileManager.default,
        sourceControlManager: SourceControlManager?
    ) {
        self.folderUrl = folderUrl
        self.ignoredFilesAndFolders = ignoredFilesAndFolders

        self.workspaceItem = CEWorkspaceFile(url: folderUrl)
        self.flattenedFileItems = [workspaceItem.id: workspaceItem]
        self.sourceControlManager = sourceControlManager
        self.fileManager = fileManager

        self.loadChildrenForFile(self.workspaceItem)

        fsEventStream = DirectoryEventStream(directory: self.folderUrl.path) { [weak self] events in
            self?.fileSystemEventReceived(events: events)
        }

        Task {
            try await self.sourceControlManager?.validate()
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
            guard let url = URL(string: path, relativeTo: folderUrl) else {
                return nil
            }

            // Drill down towards the file, indexing any directories needed. 
            // If file is not in the `workspaceSettingsFolderURL` or subdirectories, exit.
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

            if let file = flattenedFileItems[url.relativePath] {
                return file
            } else if let parent = getFile(currentURL.deletingLastPathComponent().path) {
                // This catches the case where each parent dir has been loaded, their children cached, and this is a new
                // file, so we still need to create it and add it to the cache.
                let newFileItem = createChild(url, forParent: parent)
                flattenedFileItems[newFileItem.id] = newFileItem
                childrenMap[parent.id]?.append(newFileItem.id)
                return newFileItem
            }
        }

        return nil
    }

    /// Returns all children for the given file.
    /// - Note: Will find and cache new children if they have not been already, see
    ///         ``CEWorkspaceFileManager/getFile(_:createIfNotFound:)`` to force a file to be loaded.
    /// - Parameter file: The file to find children for.
    /// - Returns: An array of children for the file, or `nil` if the file was not a directory.
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

    /// Loads and caches all children for the given file item.
    ///
    /// After calling this method, you can expect `childrenMap` to contain some value
    /// for the file object, even an empty array.
    ///
    /// - Parameter file: The file item to load children for.
    private func loadChildrenForFile(_ file: CEWorkspaceFile) {
        guard let children = urlsForDirectory(file.resolvedURL) else {
            return
        }
        var addedChildrenUrls: [String] = []
        for child in children {
            let newFileItem = createChild(child, forParent: file)
            flattenedFileItems[newFileItem.id] = newFileItem
            addedChildrenUrls.append(newFileItem.id)
        }
        childrenMap[file.id] = addedChildrenUrls
        Task {
            await sourceControlManager?.refreshAllChangedFiles()
        }
    }

    /// Creates an ordered array of all files and directories at the given file object.
    /// - Parameter file: The file to use.
    /// - Returns: An ordered array of URLs sorted alphabetically with directories first.
    private func urlsForDirectory(_ url: URL) -> [URL]? {
        try? fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.includesDirectoriesPostOrder, .skipsSubdirectoryDescendants]
        )
        .compactMap {
            ignoredFilesAndFolders.contains($0.lastPathComponent) && (try? $0.checkResourceIsReachable()) ?? false
            ? nil
            : URL(filePath: $0.path(percentEncoded: false), relativeTo: folderUrl)
        }
        .sortItems(foldersOnTop: true)
    }

    /// Creates a child item for the specified parent item. Th child item's id is based on the
    /// parent's id to take into account symlinks.
    /// - Parameter url: The file url of the child element.
    /// - Parameter file: The parent element.
    /// - Returns: A child element with an associated parent.
    func createChild(_ url: URL, forParent file: CEWorkspaceFile) -> CEWorkspaceFile {
        let relativeURL = URL(filePath: file.id).appending(path: url.lastPathComponent)
        let childId = relativeURL.relativePath
        let newFileItem = CEWorkspaceFile(id: childId, url: relativeURL)
        newFileItem.parent = file
        return newFileItem
    }

#if DEBUG
    /// Determines if the file has had it's children loaded from disk.
    /// - Parameter file: The file to check.
    /// - Returns: True if the file's children have been cached.
    func hasLoadedChildrenFor(file: CEWorkspaceFile) -> Bool {
        childrenMap[file.id] != nil
    }
#endif

    /// Run when the owner of the ``CEWorkspaceFileManager`` doesn't need it anymore.
    /// This de-inits most functions in the ``CEWorkspaceFileManager``, so that in case it isn't de-init'd it does not
    /// use up significant amounts of RAM, and clears any file system event watchers.
    func cleanUp() {
        fsEventStream?.cancel()
        flattenedFileItems = [workspaceItem.id: workspaceItem]
    }

    deinit {
        fsEventStream?.cancel()
        observers.removeAllObjects()
    }
}
