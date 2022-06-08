//
//  Live.swift
//  CodeEditModules/WorkspaceClient
//
//  Created by Marco Carnevali on 16/03/22.
//

import Combine
import Foundation

public extension WorkspaceClient {
    // swiftlint:disable:next function_body_length
    static func `default`(
        fileManager: FileManager,
        folderURL: URL,
        ignoredFilesAndFolders: [String]
    ) throws -> Self {
        var flattenedFileItems: [String: FileItem] = [:]

        func loadFiles(fromURL url: URL) throws -> [FileItem] {
            let directoryContents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            var items: [FileItem] = []

            for itemURL in directoryContents {
                // Skip file if it is in ignore list
                guard !ignoredFilesAndFolders.contains(itemURL.lastPathComponent) else { continue }

                var isDir: ObjCBool = false

                if fileManager.fileExists(atPath: itemURL.path, isDirectory: &isDir) {
                    var subItems: [FileItem]?

                    if isDir.boolValue {
                        // TODO: Possibly optimize to loading avoid cache dirs and/or large folders
                        // Recursively fetch subdirectories and files if the path points to a directory
                        subItems = try loadFiles(fromURL: itemURL)
                    }

                    let newFileItem = FileItem(url: itemURL, children: subItems?.sortItems(foldersOnTop: true))
                    subItems?.forEach {
                        $0.parent = newFileItem
                    }
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

        func rebuildFiles(fromItem fileItem: FileItem) throws {
            // TODO: don't rebuild the entire index, just add and remove items when needed.

            // get a copy of the array of actual children of directory
            let directoryContentsUrls = try fileManager.contentsOfDirectory(at: fileItem.url,
                                                                            includingPropertiesForKeys: nil)

            // get currently indexed children of directory
            var newChildren = fileItem.children?.filter({ _ in true }) // build a new array based on fileItem.children

            // test for deleted children, and remove them from the index
            for oldContent in fileItem.children ?? [] {
                if directoryContentsUrls.contains(oldContent.url) {
                    continue
                }

                if let removeAt = newChildren?.firstIndex(of: oldContent) {
                    newChildren?.remove(at: removeAt)
                    flattenedFileItems.removeValue(forKey: oldContent.id)
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

                    if isDir.boolValue {
                        subItems = try loadFiles(fromURL: newContent)
                    }

                    let newFileItem = FileItem(url: newContent, children: subItems?.sortItems(foldersOnTop: true))
                    subItems?.forEach {
                        $0.parent = newFileItem
                    }
                    newFileItem.parent = fileItem
                    flattenedFileItems[newFileItem.id] = newFileItem
                    newChildren?.append(newFileItem)
                }
            }

            newChildren?.forEach({
                try? rebuildFiles(fromItem: $0)
                flattenedFileItems[$0.id] = $0
            })

            fileItem.children = newChildren
            return
        }

        var sources: [String: DispatchSourceFileSystemObject] = [:]

        func startListeningToDirectory() {
            // iterate over every item, checking if its a directory first
            for item in flattenedFileItems.values {
                // check if it actually exists and is a folder
                guard item.isFolder else { continue }
                guard FileItem.fileManger.fileExists(atPath: item.url.path) else { continue }

                // open the folder to listen for changes
                let descriptor = open(item.url.path, O_EVTONLY)

                let source = DispatchSource.makeFileSystemObjectSource(
                    fileDescriptor: descriptor,
                    eventMask: .write,
                    queue: DispatchQueue.global()
                )

                source.setEventHandler {
                    // Something has changed inside the directory
                    // We should reload the files.
                    flattenedFileItems = [:]
                    flattenedFileItems[workspaceItem.id] = workspaceItem
//                    try rebuildFiles(fromItem: workspaceItem)
//                    subject.send(workspaceItem.children)
                    try? rebuildFiles(fromItem: workspaceItem)
                    subject.send(workspaceItem.children ?? [])
                    stopListeningToDirectory()
                    startListeningToDirectory()
                    // reload data in outline view controller through the main thread
                    DispatchQueue.main.async { onRefresh() }
                }

                source.setCancelHandler {
                    close(descriptor)
                }

                source.resume()

                sources[item.id] = source
            }
        }

        func stopListeningToDirectory() {
            for source in sources.values {
                source.cancel()
            }
            sources = [:]
        }

        func stopListeningToDirectory(directory: URL) {
            sources[directory.path]?.cancel()
            sources.removeValue(forKey: directory.path)
        }

        return Self(
            folderURL: { folderURL },
            getFiles: subject
                .handleEvents(receiveSubscription: { _ in
                    startListeningToDirectory()
                }, receiveCancel: {
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
