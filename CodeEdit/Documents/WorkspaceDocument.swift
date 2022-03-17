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
