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

            print("Loading file: \(url.absoluteString)")

            for itemURL in directoryContents {
                // Skip file if it is in ignore list
                guard !ignoredFilesAndFolders.contains(itemURL.lastPathComponent) else {
                    print("    Ignored")
                    continue
                }

                var isDir: ObjCBool = false

                if fileManager.fileExists(atPath: itemURL.path, isDirectory: &isDir) {
                    var subItems: [FileItem]?

                    if isDir.boolValue {
                        // TODO: Possibly optimize to loading avoid cache dirs and/or large folders
                        // Recursively fetch subdirectories and files if the path points to a directory
                        print("    Loading recursive file \(itemURL.absoluteString)")
                        subItems = try loadFiles(fromURL: itemURL)
                    }

                    let newFileItem = FileItem(url: itemURL, children: subItems?.sortItems(foldersOnTop: true))
                    subItems?.forEach {
                        print("    Calculating parent for subItem \($0.url)")
                        $0.parent = newFileItem
                    }
                    items.append(newFileItem)
                    flattenedFileItems[newFileItem.id] = newFileItem
                } else {
                    print("    File does not exist, or is not directory")
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
        // By using `CurrentValueSubject` we can define a starting value.
        // The value passed during init it's going to be send as soon as the
        // consumer subscribes to the publisher.
        let subject = CurrentValueSubject<[FileItem], Never>(fileItems)

        var sources = [DispatchSourceFileSystemObject?]()

        func startListeningToDirectory(_ fromURL: URL = folderURL) {
            print("Listening to \(fromURL.absoluteString)")
            // open the folder to listen for changes
            let descriptor = open(fromURL.path, O_EVTONLY)

            sources.append(DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: descriptor,
                eventMask: .write,
                queue: DispatchQueue.global()
            ))

            sources.last!?.setEventHandler {
                // Something has changed inside the directory
                // We should reload the files.
                if let fileItems = try? loadFiles(fromURL: folderURL) {
                    startListeningToDirectory(fromURL)
                    subject.send(fileItems)
                }
            }

            sources.last!?.setCancelHandler {
                close(descriptor)
            }

            sources.last!?.resume()

            // see if there are any child folders and listen to them
            do {
                let directoryContents = try fileManager.contentsOfDirectory(at:
                                                                                fromURL,
                                                                                includingPropertiesForKeys: nil)
                for itemURL in directoryContents {
                    // Skip file if it is in ignore list
                    guard !ignoredFilesAndFolders.contains(itemURL.lastPathComponent) else { continue }

                    var isDir: ObjCBool = false

                    if fileManager.fileExists(atPath: itemURL.path, isDirectory: &isDir) {
                        if isDir.boolValue {
                            startListeningToDirectory(itemURL)
                        }
                    }
                }
            } catch {}
        }

        func stopListeningToDirectory() {
            for source in sources {
                source?.cancel()
            }
            sources = []
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
