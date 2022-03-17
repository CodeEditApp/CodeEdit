//
//  WorkspaceDocument.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 17.03.22.
//

import Foundation
import AppKit
import SwiftUI
import WorkspaceClient

@objc(WorkspaceDocument)
class WorkspaceDocument: NSDocument, ObservableObject, NSToolbarDelegate {
    
    @Published var workspaceClient: WorkspaceClient?
    @Published var selectedId: UUID?
    @Published var openFileItems: [WorkspaceClient.FileItem] = []
    
    var openedCodeFiles: [WorkspaceClient.FileItem : CodeFile] = [:]
    
    func closeFileTab(item: WorkspaceClient.FileItem) {
        defer {
            openedCodeFiles.removeValue(forKey: item)
        }
        
        guard let idx = openFileItems.firstIndex(of: item) else { return }
        let closedFileItem = openFileItems.remove(at: idx)
        guard closedFileItem.id == selectedId else { return }
        
        if openFileItems.isEmpty {
            selectedId = nil
        } else if idx == 0 {
            selectedId = openFileItems.first?.id
        } else {
            selectedId = openFileItems[idx - 1].id
        }
    }
    
    func openFile(item: WorkspaceClient.FileItem) {
        do {
            let codeFile = try CodeFile(for: item.url, withContentsOf: item.url, ofType: "public.source-code")
            
            if !openFileItems.contains(item) {
                openFileItems.append(item)
                
                openedCodeFiles[item] = codeFile
            }
            selectedId = item.id
            
            self.windowControllers.first?.window?.subtitle = item.url.lastPathComponent
        } catch let e {
            Swift.print(e)
        }
    }
    
    private let ignoredFilesAndDirectory = [
        ".DS_Store",
    ]
    
    override class var autosavesInPlace: Bool {
        return true
    }
        
    override func makeWindowControllers() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.toolbar = NSToolbar()
        window.toolbarStyle = .unifiedCompact
        window.titlebarSeparatorStyle = .none
        window.titlebarAppearsTransparent = true
        
        window.toolbar?.displayMode = .iconOnly
        window.toolbar?.insertItem(withItemIdentifier: .toggleSidebar, at: 0)
        let windowController = NSWindowController(window: window)
        let contentView = WorkspaceView(windowController: windowController, workspace: self)
        window.contentView = NSHostingView(rootView: contentView)
        self.addWindowController(windowController)
    }
    
    override func read(from url: URL, ofType typeName: String) throws {
        self.workspaceClient = try .default(
            fileManager: .default,
            folderURL: url,
            ignoredFilesAndFolders: ignoredFilesAndDirectory
        )
    }
    
    override func write(to url: URL, ofType typeName: String) throws {
        
    }
}
