//
//  Workspace.swift
//  CodeEdit
//
//  Created by Rehatbir Singh on 12/03/2022.
//

import Foundation
import AppKit
import SwiftUI

@objc(Workspace)
class Workspace: NSDocument, ObservableObject {
    
    static let ignoredFilesAndFolders = [
        ".DS_Store"
    ]
    
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
    
    // MARK: - NSDocument
    
    override class var autosavesInPlace: Bool {
        return true
    }
    
    override func makeWindowControllers() {
        let contentView = WorkspaceView(workspace: self)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.contentView = NSHostingView(rootView: contentView)
        window.toolbar = NSToolbar()
        window.toolbarStyle = .unified
        let windowController = NSWindowController(window: window)
        self.addWindowController(windowController)
    }
    
    override func read(from url: URL, ofType typeName: String) throws {
        fileItems = try getFileItems(url: url)
    }
    
}
