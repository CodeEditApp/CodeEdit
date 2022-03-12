//
//  Workspace.swift
//  CodeEdit
//
//  Created by Rehatbir Singh on 12/03/2022.
//

import Foundation

struct Workspace {
    
    static let ignoredFilesAndFolders = [
        ".DS_Store"
    ]
    
    var directoryURL: URL
    var fileItems: [FileItem] = []
    
    private func getFileItems(url: URL) throws -> [FileItem] {
        let directoryContents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        var items: [FileItem] = []
        
        for url in directoryContents {
            // Skip file if it is in ignore list
            guard !Workspace.ignoredFilesAndFolders.contains(url.lastPathComponent) else { continue }
            
            var isDir: ObjCBool = false
            
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
                var subItems: [FileItem]? = nil
                
                if isDir.boolValue {
                    // TODO: Possibly optimize to loading avoid cache dirs and/or large folders
                    // Recursively fetch subdirectories and files if the path points to a directory
                    subItems = try getFileItems(url: url)
                }
                
                let newFileItem = FileItem(url: url, children: subItems)
                items.append(newFileItem)
            }
        }
        
        return items
    }
    
    init(folderURL: URL) throws {
        directoryURL = folderURL
        fileItems = try getFileItems(url: folderURL)
    }
    
}
