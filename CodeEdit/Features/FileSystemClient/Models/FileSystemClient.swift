//
//  FileSystemClient.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 04/02/2023.
//

import Combine
import Foundation

/// This class is used to load the files of the machine into a CodeEdit workspace.
final class FileSystemClient {

    enum FileSystemClientError: Error {
        case fileNotExist
    }

    private var subject = CurrentValueSubject<[FileSystemItem], Never>([])
    private var isRunning = false
    private var anotherInstanceRan = 0

    private(set) var fileManager = FileManager.default
    private(set) var ignoredFilesAndFolders: [String]
    private(set) var flattenedFileItems: [String: FileSystemItem]

    var onRefresh: () -> Void = {}
    var getFiles: AnyPublisher<[FileSystemItem], Never> =
        CurrentValueSubject<[FileSystemItem], Never>([]).eraseToAnyPublisher()

    let folderUrl: URL
    let workspaceItem: FileSystemItem

    init(folderUrl: URL, ignoredFilesAndFolders: [String]) {
        self.folderUrl = folderUrl
        self.ignoredFilesAndFolders = ignoredFilesAndFolders

        self.workspaceItem = FileSystemItem(url: folderUrl, children: [])
        self.flattenedFileItems = [workspaceItem.id: workspaceItem]
    }

    /// Recursive loading of files into `FileItem`s
    /// - Parameter url: The URL of the directory to load the items of
    /// - Returns: `[FileItem]` representing the contents of the directory
    private func loadFiles(fromURL url: URL) throws -> [FileSystemItem] {
        let directoryContents = try fileManager.contentsOfDirectory(
            at: url.resolvingSymlinksInPath(),
            includingPropertiesForKeys: nil
        )
        var items: [FileSystemItem] = []

        for itemURL in directoryContents {
            guard !ignoredFilesAndFolders.contains(itemURL.lastPathComponent) else { continue }

            var isDir: ObjCBool = false

            if fileManager.fileExists(atPath: itemURL.path, isDirectory: &isDir) {
                var subItems: [FileSystemItem]?

                if isDir.boolValue {
                    // Recursively fetch subdirectories and files if the path points to a directory
                    subItems = try loadFiles(fromURL: itemURL)
                }

                let newFileItem = FileSystemItem(
                    url: itemURL,
                    children: subItems?.sortItems(foldersOnTop: true)
                )

                // note: watcher code will be applied after the workspaceItem is created
                newFileItem.watcherCode = { sourceFileItem in
                    self.reloadFromWatcher(sourceFileItem: sourceFileItem)
                }
                subItems?.forEach { $0.parent = newFileItem }
                items.append(newFileItem)
                flattenedFileItems[newFileItem.id] = newFileItem
            }
        }

        return items
    }

    /// A function that, given a file's path, returns a `FileItem` if it exists
    /// within the scope of the `FileSystemClient`.
    /// - Parameter id: The file's full path
    /// - Returns: The file item corresponding to the file
    func getFileItem(_ id: String) throws -> FileSystemItem {
        guard let item = flattenedFileItems[id] else {
            throw FileSystemClientError.fileNotExist
        }

        return item
    }

    /// Usually run when the owner of the `FileSystemClient` doesn't need it anymore.
    /// This de-inits most functions in the `FileSystemClient`, so that in case it isn't de-init'd it does not use up
    /// significant amounts of RAM.
    func cleanUp() {
        stopListeningToDirectory()
        workspaceItem.children = []
        flattenedFileItems = [workspaceItem.id: workspaceItem]
        print("Cleaned up watchers and file items")
    }

    // run by dispatchsource watchers. Multiple instances may be concurrent,
    // so we need to be careful to avoid EXC_BAD_ACCESS errors.
    /// This is a function run by `DispatchSource` file watchers. Due to the nature of watchers, multiple
    /// instances may be running concurrently, so the function prevents more than one instance of it from
    /// running the main code body.
    /// - Parameter sourceFileItem: The `FileItem` corresponding to the file that triggered the `DispatchSource`
    func reloadFromWatcher(sourceFileItem: FileSystemItem) {
        // Something has changed inside the directory
        // We should reload the files.
        guard !isRunning else { // this runs when a file change is detected but is already running
            anotherInstanceRan += 1
            return
        }
        isRunning = true

        // inital reload of files
        _ = try? rebuildFiles(fromItem: sourceFileItem)

        // re-reload if another instance tried to run while this instance was running
        // TODO: optimise
        while anotherInstanceRan > 0 {
            let somethingChanged = try? rebuildFiles(fromItem: workspaceItem)
            anotherInstanceRan = !(somethingChanged ?? false) ? 0 : anotherInstanceRan - 1
        }

        subject.send(workspaceItem.children ?? [])
        isRunning = false
        anotherInstanceRan = 0

        // reload data in outline view controller through the main thread
        DispatchQueue.main.async {
            self.onRefresh()
        }
    }

    /// A function to kill the watcher of a specific directory, or all directories.
    /// - Parameter directory: The directory to stop watching, or nil to stop watching everything.
    func stopListeningToDirectory(directory: URL? = nil) {
        if directory != nil {
            flattenedFileItems[directory!.relativePath]?.watcher?.cancel()
        } else {
            for item in flattenedFileItems.values {
                item.watcher?.cancel()
                item.watcher = nil
            }
        }
    }

    /// Recursive function similar to `loadFiles`, but creates or deletes children of the
    /// `FileItem` so that they are accurate with the file system, instead of creating an
    /// entirely new `FileItem`, to prevent the `OutlineView` from going crazy with folding.
    /// - Parameter fileItem: The `FileItem` to correct the children of
    @discardableResult
    func rebuildFiles(fromItem fileItem: FileSystemItem) throws -> Bool {
        var didChangeSomething = false

        // get the actual directory children
        let directoryContentsUrls = try fileManager.contentsOfDirectory(
            at: fileItem.url.resolvingSymlinksInPath(),
            includingPropertiesForKeys: nil
        )

        // test for deleted children, and remove them from the index
        for oldContent in fileItem.children ?? [] where !directoryContentsUrls.contains(oldContent.url) {
            if let removeAt = fileItem.children?.firstIndex(of: oldContent) {
                fileItem.children?[removeAt].watcher?.cancel()
                fileItem.children?.remove(at: removeAt)
                flattenedFileItems.removeValue(forKey: oldContent.id)
                didChangeSomething = true
            }
        }

        // test for new children, and index them using loadFiles
        for newContent in directoryContentsUrls {
            guard !ignoredFilesAndFolders.contains(newContent.lastPathComponent) else { continue }

            // if the child has already been indexed, continue to the next item.
            guard !(fileItem.children?.map({ $0.url }).contains(newContent) ?? false) else { continue }

            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: newContent.path, isDirectory: &isDir) {
                var subItems: [FileSystemItem]?

                if isDir.boolValue { subItems = try loadFiles(fromURL: newContent) }

                let newFileItem = FileSystemItem(
                    url: newContent,
                    children: subItems?.sortItems(foldersOnTop: true)
                )

                newFileItem.watcherCode = { sourceFileItem in
                    self.reloadFromWatcher(sourceFileItem: sourceFileItem)
                }

                subItems?.forEach { $0.parent = newFileItem }

                newFileItem.parent = fileItem
                flattenedFileItems[newFileItem.id] = newFileItem
                fileItem.children?.append(newFileItem)
                didChangeSomething = true
            }
        }

        fileItem.children = fileItem.children?.sortItems(foldersOnTop: true)
        fileItem.children?.forEach({
            if $0.isFolder {
                let childChanged = try? rebuildFiles(fromItem: $0)
                didChangeSomething = (childChanged ?? false) ? true : didChangeSomething
            }
            flattenedFileItems[$0.id] = $0
        })

        return didChangeSomething
    }

}
