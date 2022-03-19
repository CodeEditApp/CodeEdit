//
//  CodeEditorAppDelegate.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 12.03.22.
//

import SwiftUI

class CodeEditApplication: NSApplication {

    let strongDelegate = AppDelegate()

    override init() {
        super.init()
        self.delegate = strongDelegate
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        _ = CodeEditDocumentController.shared
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let appearanceString = UserDefaults.standard.string(forKey: Appearances.storageKey) {
            Appearances(rawValue: appearanceString)?.applyAppearance()
        }
        
        handleOpen()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    @IBAction func openPreferences(_ sender: Any) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.toolbar = NSToolbar()
        window.title = "Settings"
        window.toolbarStyle = .unifiedCompact
        let _ = NSWindowController(window: window)
        let contentView = SettingsView()
        window.contentView = NSHostingView(rootView: contentView)
        
        window.makeKeyAndOrderFront(sender)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            return false
        }
        
        handleOpen()
        
        return false
    }
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func handleOpen() {
        let behavior = ReopenBehavior(rawValue: UserDefaults.standard.string(forKey: ReopenBehavior.storageKey) ?? ReopenBehavior.openPanel.rawValue) ?? ReopenBehavior.openPanel
        
        switch behavior {
        case .welcome:
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 780, height: 500), styleMask: [.borderless], backing: .buffered, defer: false)
            let windowController = NSWindowController(window: window)
            window.center()
            let contentView = WelcomeWindowView(windowController: windowController)
            window.isMovableByWindowBackground = true
            window.contentView = NSHostingView(rootView: contentView)
            window.isOpaque = false
            window.backgroundColor = .clear
            window.contentView?.wantsLayer = true
            window.contentView?.layer?.masksToBounds = true
            window.contentView?.layer?.cornerRadius = 10
            window.hasShadow = true
            window.makeKeyAndOrderFront(self)
        case .openPanel:
            CodeEditDocumentController.shared.openDocument(self)
        case .newDocument:
            CodeEditDocumentController.shared.newDocument(self)
        }
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        CodeEditDocumentController.shared.documents.flatMap { doc in
            return doc.windowControllers
        }.forEach { (wc : NSWindowController) in
            if let wc = wc as? CodeEditWindowController {
                wc.workspace?.close()
            }
        }
        return .terminateNow
    }
}
