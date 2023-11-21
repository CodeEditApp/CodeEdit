//
//  FileSystemClient.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 04/02/2023.
//

import Combine
import Foundation
import AppKit

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
    private(set) var fileManager: FileManager
    private(set) var ignoredFilesAndFolders: Set<String>
    private(set) var flattenedFileItems: [String: CEWorkspaceFile]
    /// Maps all directories to it's children's paths.
    private var childrenMap: [String: [String]] = [:]
    private var fsEventStream: DirectoryEventStream?
    private var observers: NSHashTable<AnyObject> = .weakObjects()

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

        sourceControlManager?.isGitRepository = fileManager.fileExists(atPath: "\(folderUrl.relativePath)/.git")
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
        guard let children = urlsForDirectory(file) else {
            return
        }
        for child in children {
            let newFileItem = CEWorkspaceFile(url: child)
            newFileItem.parent = file
            flattenedFileItems[newFileItem.id] = newFileItem
        }
        childrenMap[file.id] = children.map { $0.relativePath }
        Task {
            await sourceControlManager?.refreshAllChangedFiles()
        }
    }

    /// Creates an ordered array of all files and directories at the given file object.
    /// - Parameter file: The file to use.
    /// - Returns: An ordered array of URLs sorted alphabetically with directories first.
    private func urlsForDirectory(_ file: CEWorkspaceFile) -> [URL]? {
        try? fileManager.contentsOfDirectory(
            at: file.url,
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

#if DEBUG
    /// Determines if the file has had it's children loaded from disk.
    /// - Parameter file: The file to check.
    /// - Returns: True if the file's children have been cached.
    func hasLoadedChildrenFor(file: CEWorkspaceFile) -> Bool {
        childrenMap[file.id] != nil
    }
#endif

    // MARK: - Directory Events

    /// Run when the owner of the ``CEWorkspaceFileManager`` doesn't need it anymore.
    /// This de-inits most functions in the ``CEWorkspaceFileManager``, so that in case it isn't de-init'd it does not
    /// use up significant amounts of RAM, and clears any file system event watchers.
    func cleanUp() {
        fsEventStream?.cancel()
        flattenedFileItems = [workspaceItem.id: workspaceItem]
    }

    /// Called by `fsEventStream` when an event occurs.
    ///
    /// This method may be called on a background thread, but all work done by this function will be queued on the main
    /// thread.
    /// - Parameter events: An array of events that occurred.
    private func fileSystemEventReceived(events: [DirectoryEventStream.Event]) {
        DispatchQueue.main.async {
            var files: Set<CEWorkspaceFile> = []
            for event in events {
                // Event returns file/folder that was changed, but in tree we need to update it's parent
                let parent = "/" + event.path.split(separator: "/").dropLast().joined(separator: "/")
                guard let parentItem = self.getFile(parent) else {
                    continue
                }

                switch event.eventType {
                case .changeInDirectory, .itemChangedOwner, .itemModified:
                    // Can be ignored for now, these I think not related to tree changes
                    continue
                case .rootChanged:
                    // TODO: Handle workspace root changing.
                    continue
                case .itemCreated, .itemCloned, .itemRemoved, .itemRenamed:
                    try? self.rebuildFiles(fromItem: parentItem)
                    files.insert(parentItem)
                }
            }
            if !files.isEmpty {
                self.notifyObservers(updatedItems: files)
            }

            // Changes excluding .git folder
            let notGitChanges = events.filter({ !$0.path.contains(".git/") })

            // .git folder was changed
            let gitFolderChange = events.first(where: { $0.path == "\(self.folderUrl.relativePath)/.git" })

            // Change made to staged files by looking at .git/index
            let gitIndexChange = events.first(where: { $0.path == "\(self.folderUrl.relativePath)/.git/index" })

            // Change made to git stash file by looking at .git/refs/stash
            let gitStashChange = events.first(where: { $0.path == "\(self.folderUrl.relativePath)/.git/refs/stash" })

            // Change made to remotes by looking at .git/config
            let gitConfigChange = events.first(where: { $0.path == "\(self.folderUrl.relativePath)/.git/config" })

            // If changes were made to project OR files were staged, refresh our changes
            if !notGitChanges.isEmpty || gitIndexChange != nil {
                Task {
                    await self.sourceControlManager?.refreshAllChangedFiles()
                }
            }

            // If changeds were stashed, refresh our changes
            if gitStashChange != nil {
                Task {
                    try await self.sourceControlManager?.refreshStashEntries()
                }
            }

            if gitConfigChange != nil {
                Task {
                    try await self.sourceControlManager?.refreshRemotes()
                }
            }

            if gitFolderChange != nil {
                self.sourceControlManager?.isGitRepository = self.fileManager.fileExists(
                    atPath: "\(self.folderUrl.relativePath)/.git"
                )
            }
        }
    }

    /// Creates or deletes children of the ``CEWorkspaceFile`` so that they are accurate with the file system,
    /// instead of creating an entirely new ``CEWorkspaceFile``. Can optionally run a deep rebuild.
    ///
    /// This method will return immediately if the given file item is not a directory.
    /// This will also only rebuild *already cached* directories.
    /// - Parameters:
    ///   - fileItem: The ``CEWorkspaceFile``  to correct the children of
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
        // Folders may or may not have slash at the end, this will normalize check
        let directoryContentsUrlsRelativePaths = directoryContentsUrls.map({ $0.relativePath })
        for (idx, oldURL) in (childrenMap[fileItem.id] ?? []).map({ URL(filePath: $0) }).enumerated().reversed()
        where !directoryContentsUrlsRelativePaths.contains(oldURL.relativePath) {
            flattenedFileItems.removeValue(forKey: oldURL.relativePath)
            childrenMap[fileItem.id]?.remove(at: idx)
        }

        // test for new children, and index them
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
                try rebuildFiles(fromItem: child)
            }
        }
    }

    /// Notify observers that an update occurred in the watched files.
    func notifyObservers(updatedItems: Set<CEWorkspaceFile>) {
        observers.allObjects.reversed().forEach { delegate in
            guard let delegate = delegate as? CEWorkspaceFileManagerObserver else {
                observers.remove(delegate)
                return
            }
            delegate.fileManagerUpdated(updatedItems: updatedItems)
        }
    }

    /// Add an observer for file system events.
    /// - Parameter observer: The observer to add.
    func addObserver(_ observer: CEWorkspaceFileManagerObserver) {
        observers.add(observer as AnyObject)
    }

    /// Remove an observer for file system events.
    /// - Parameter observer: The observer to remove.
    func removeObserver(_ observer: CEWorkspaceFileManagerObserver) {
        observers.remove(observer as AnyObject)
    }

    deinit {
        observers.removeAllObjects()
    }
}
