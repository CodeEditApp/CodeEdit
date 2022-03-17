//
//  Live.swift
//  CodeEdit
//
//  Created by Marco Carnevali on 16/03/22.
//

import Foundation

public extension WorkspaceClient {
    static func `default`(
        fileManager: FileManager,
        folderURL: URL,
        ignoredFilesAndFolders: [String]
    ) throws -> Self {
        var fileItems: [FileItem] = []
        var flattenedFileItems: [UUID: FileItem] = [:]
        
        func loadFiles(fromURL url: URL) throws -> [FileItem] {
            let directoryContents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            var items: [FileItem] = []
            
            for itemURL in directoryContents {
                // Skip file if it is in ignore list
                guard !ignoredFilesAndFolders.contains(itemURL.lastPathComponent) else { continue }
                
                var isDir: ObjCBool = false
                
                if fileManager.fileExists(atPath: itemURL.path, isDirectory: &isDir) {
                    var subItems: [FileItem]? = nil
                    
                    if isDir.boolValue {
                        // TODO: Possibly optimize to loading avoid cache dirs and/or large folders
                        // Recursively fetch subdirectories and files if the path points to a directory
                        subItems = try loadFiles(fromURL: itemURL)
                    }
                    
                    let newFileItem = FileItem(url: itemURL, children: subItems)
                    items.append(newFileItem)
                    flattenedFileItems[newFileItem.id] = newFileItem
                }
            }
            
            return items
        }
        
        fileItems = try loadFiles(fromURL: folderURL)
        
        return Self(
            getFiles: { fileItems },
            getFileItem: { id in
                guard let item = flattenedFileItems[id] else {
                    throw WorkspaceClientError.fileNotExist
                }
                return item
            }
        )
    }
}
