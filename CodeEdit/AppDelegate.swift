//
//  CodeEditorAppDelegate.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 12.03.22.
//

import SwiftUI
import Preferences

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

        DispatchQueue.main.async {
            if NSApp.windows.isEmpty {
                self.handleOpen()
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
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
        let behavior = ReopenBehavior(rawValue: UserDefaults.standard.string(forKey: ReopenBehavior.storageKey)
                                      ?? ReopenBehavior.default.rawValue) ?? ReopenBehavior.default

        switch behavior {
        case .welcome:
            openWelcome(self)
        case .openPanel:
            CodeEditDocumentController.shared.openDocument(self)
        case .newDocument:
            CodeEditDocumentController.shared.newDocument(self)
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        CodeEditDocumentController.shared.documents.flatMap { doc in
            return doc.windowControllers
        }.forEach { windowContoller in
            if let windowContoller = windowContoller as? CodeEditWindowController {
                windowContoller.workspace?.close()
            }
        }
        return .terminateNow
    }

    // MARK: - Open windows
    private lazy var preferencesWindowController = PreferencesWindowController(
        panes: [
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier.general,
                title: "General",
                toolbarIcon: NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)!
            ) {
                GeneralSettingsView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier.theme,
                title: "Theme",
                toolbarIcon: NSImage(systemSymbolName: "paintbrush", accessibilityDescription: nil)!
            ) {
                ThemeSettingsView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier.execution,
                title: "Execution",
                toolbarIcon: NSImage(systemSymbolName: "arrowtriangle.forward", accessibilityDescription: nil)!
            ) {
                ExecutionSettingsView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier.extension,
                title: "Extensions",
                toolbarIcon: NSImage(systemSymbolName: "shippingbox", accessibilityDescription: nil)!
            ) {
                ExtensionsSettingsView()
            },
        ]
    )

    @IBAction func openPreferences(_ sender: Any) {
        preferencesWindowController.show()
        preferencesWindowController.window?.center()
    }

    @IBAction func openWelcome(_ sender: Any) {
        if let window = NSApp.windows.filter({ window in
            return (window.contentView as? NSHostingView<WelcomeWindowView>) != nil
        }).first {
            window.makeKeyAndOrderFront(self)
            return
        }

        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 800, height: 460),
                              styleMask: [.titled, .fullSizeContentView], backing: .buffered, defer: false)
        let windowController = NSWindowController(window: window)
        window.center()
        let contentView = WelcomeWindowView(windowController: windowController)
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(self)
    }
}
