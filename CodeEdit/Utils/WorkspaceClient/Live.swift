//
//  Live.swift
//  CodeEditModules/WorkspaceClient
//
//  Created by Marco Carnevali on 16/03/22.
//

import Combine
import Foundation

// TODO: DOCS (Marco Carnevali)
extension WorkspaceClient {
    // swiftlint:disable:next function_body_length
    static func `default`(
        fileManager: FileManager,
        folderURL: URL,
        ignoredFilesAndFolders: [String]
    ) throws -> Self {
        var flattenedFileItems: [String: FileItem] = [:]

        // Recursive loading of files into `FileItem`s
        // - Parameter url: The URL of the directory to load the items of
        // - Returns: `[FileItem]` representing the contents of the directory
        func loadFiles(fromURL url: URL) throws -> [FileItem] {
            let directoryContents = try fileManager.contentsOfDirectory(at: url.resolvingSymlinksInPath(),
                                                                        includingPropertiesForKeys: nil)
            var items: [FileItem] = []

            for itemURL in directoryContents {
                // Skip file if it is in ignore list
                guard !ignoredFilesAndFolders.contains(itemURL.lastPathComponent) else { continue }

                var isDir: ObjCBool = false

                if fileManager.fileExists(atPath: itemURL.path, isDirectory: &isDir) {
                    var subItems: [FileItem]?

                    if isDir.boolValue {
                        // Recursively fetch subdirectories and files if the path points to a directory
                        subItems = try loadFiles(fromURL: itemURL)
                    }

                    let newFileItem = FileItem(url: itemURL, children: subItems?.sortItems(foldersOnTop: true))
                    subItems?.forEach { $0.parent = newFileItem }
                    items.append(newFileItem)
                    flattenedFileItems[newFileItem.id] = newFileItem
                }
            }

            return items
        }

        // initial load
        let fileItems = try loadFiles(fromURL: folderURL)
        // workspace fileItem
        let workspaceItem = FileItem(url: folderURL, children: fileItems)
        flattenedFileItems[workspaceItem.id] = workspaceItem
        fileItems.forEach { item in
            item.parent = workspaceItem
        }

        // By using `CurrentValueSubject` we can define a starting value.
        // The value passed during init it's going to be send as soon as the
        // consumer subscribes to the publisher.
        let subject = CurrentValueSubject<[FileItem], Never>(fileItems)

        var isRunning: Bool = false
        var anotherInstanceRan: Int = 0

        // Recursive function similar to `loadFiles`, but creates or deletes children of the
        // `FileItem` so that they are accurate with the file system, instead of creating an
        // entirely new `FileItem`, to prevent the `OutlineView` from going crazy with folding.
        // - Parameter fileItem: The `FileItem` to correct the children of
        func rebuildFiles(fromItem fileItem: FileItem) throws -> Bool {
            var didChangeSomething = false

            // get the actual directory children
            let directoryContentsUrls = try fileManager.contentsOfDirectory(at: fileItem.url.resolvingSymlinksInPath(),
                                                                            includingPropertiesForKeys: nil)

            // test for deleted children, and remove them from the index
            for oldContent in fileItem.children ?? [] where !directoryContentsUrls.contains(oldContent.url) {
                if let removeAt = fileItem.children?.firstIndex(of: oldContent) {
                    fileItem.children?.remove(at: removeAt)
                    flattenedFileItems.removeValue(forKey: oldContent.id)
                    didChangeSomething = true
                }
            }

            // test for new children, and index them using loadFiles
            for newContent in directoryContentsUrls {
                guard !ignoredFilesAndFolders.contains(newContent.lastPathComponent) else { continue }

                var childExists = false
                fileItem.children?.forEach({ childExists = $0.url == newContent ? true : childExists })
                if childExists {
                    continue
                }

                var isDir: ObjCBool = false
                if fileManager.fileExists(atPath: newContent.path, isDirectory: &isDir) {
                    var subItems: [FileItem]?

                    if isDir.boolValue { subItems = try loadFiles(fromURL: newContent) }

                    let newFileItem = FileItem(url: newContent, children: subItems?.sortItems(foldersOnTop: true))
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

        FileItem.watcherCode = {
            // Something has changed inside the directory
            // We should reload the files.
            guard !isRunning else { // this runs when a file change is detected but is already running
                anotherInstanceRan += 1
                return
            }
            isRunning = true
            flattenedFileItems = [workspaceItem.id: workspaceItem]
            _ = try? rebuildFiles(fromItem: workspaceItem)
            while anotherInstanceRan > 0 { // TODO: optimise
                let somethingChanged = try? rebuildFiles(fromItem: workspaceItem)
                anotherInstanceRan = !(somethingChanged ?? false) ? 0 : anotherInstanceRan - 1
            }
            subject.send(workspaceItem.children ?? [])
            isRunning = false
            anotherInstanceRan = 0
            // reload data in outline view controller through the main thread
            DispatchQueue.main.async { onRefresh() }
        }

        func stopListeningToDirectory(directory: URL? = nil) {
            if directory != nil {
                flattenedFileItems[directory!.relativePath]?.watcher?.cancel()
            } else {
                for item in flattenedFileItems.values {
                    item.watcher?.cancel()
                }
            }
        }

        return Self(
            folderURL: { folderURL },
            getFiles: subject
                .handleEvents(receiveCancel: {
                    stopListeningToDirectory()
                })
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher(),
            getFileItem: { id in
                guard let item = flattenedFileItems[id] else {
                    throw WorkspaceClientError.fileNotExist
                }
                return item
            }
        )
    }
}
