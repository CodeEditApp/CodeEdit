//
//  CodeEditorAppDelegate.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 12.03.22.
//

import SwiftUI
import AppPreferences
import Preferences
import About
import WelcomeModule
import ExtensionsStore
import Feedback
import CodeEditSymbols

final class CodeEditApplication: NSApplication {
    let strongDelegate = AppDelegate()

    override init() {
        super.init()
        self.delegate = strongDelegate
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    func applicationWillFinishLaunching(_ notification: Notification) {
        _ = CodeEditDocumentController.shared
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppPreferencesModel.shared.preferences.general.appAppearance.applyAppearance()
        checkForFilesToOpen()

        DispatchQueue.main.async {
            if NSApp.windows.isEmpty {
                if let projects = UserDefaults.standard.array(forKey: AppDelegate.recoverWorkspacesKey) as? [String],
                   !projects.isEmpty {
                    projects.forEach { path in
                        let url = URL(fileURLWithPath: path)
                        CodeEditDocumentController.shared.reopenDocument(for: url,
                                                                        withContentsOf: url,
                                                                        display: true) { document, _, _ in
                            document?.windowControllers.first?.synchronizeWindowTitleWithDocumentName()
                        }
                    }
                    return
                }

                self.handleOpen()
            }
        }

        do {
            try ExtensionsManager.shared?.preload()
        } catch let error {
            print(error)
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
        let behavior = AppPreferencesModel.shared.preferences.general.reopenBehavior

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
        let projects: [String] = CodeEditDocumentController.shared.documents
            .map { doc in
                return (doc as? WorkspaceDocument)?.fileURL?.path
            }
            .filter { $0 != nil }
            .map { $0! }

        UserDefaults.standard.set(projects, forKey: AppDelegate.recoverWorkspacesKey)

        CodeEditDocumentController.shared.documents.forEach { doc in
            doc.close()
            CodeEditDocumentController.shared.removeDocument(doc)
        }
        return .terminateNow
    }

    // MARK: - Open windows

    @IBAction func openPreferences(_ sender: Any) {
        preferencesWindowController.show()
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
        let contentView = WelcomeWindowView(
            shellClient: Current.shellClient,
            openDocument: { url, opened in
                if let url = url {
                    CodeEditDocumentController.shared.openDocument(
                        withContentsOf: url,
                        display: true
                    ) { doc, _, _ in
                        if doc != nil {
                            opened()
                        }
                    }

                } else {
                    windowController.window?.close()
                    CodeEditDocumentController.shared.openDocument(onCompletion: { _, _ in
                        opened()
                    }, onCancel: {
                        self.openWelcome(self)
                    })
                }
            },
            newDocument: {
                CodeEditDocumentController.shared.newDocument(nil)
            },
            dismissWindow: {
                windowController.window?.close()
            }
        )
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(self)
    }

    @IBAction func openAbout(_ sender: Any) {
        AboutView().showWindow(width: 530, height: 220)
    }

    @IBAction func openFeedback(_ sender: Any) {
        FeedbackView().showWindow()
    }

    // MARK: - Open With CodeEdit (Extension) functions
    private func checkForFilesToOpen() {
        guard let defaults = UserDefaults.init(
            suiteName: "austincondiff.CodeEdit.shared"
        ) else {
            print("Failed to get/init shared defaults")
            return
        }

        // Register enableOpenInCE (enable Open In CodeEdit
        defaults.register(defaults: ["enableOpenInCE": true])

        if let filesToOpen = defaults.string(forKey: "openInCEFiles") {
            let files = filesToOpen.split(separator: ";")

            for filePath in files {
                let fileURL = URL(fileURLWithPath: String(filePath))
                CodeEditDocumentController.shared.reopenDocument(
                    for: fileURL,
                    withContentsOf: fileURL,
                    display: true) { document, _, _ in
                        document?.windowControllers.first?.synchronizeWindowTitleWithDocumentName()
                    }
            }

            defaults.removeObject(forKey: "openInCEFiles")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.checkForFilesToOpen()
        }
    }

    // MARK: - Preferences
    private lazy var preferencesWindowController = PreferencesWindowController(
        panes: [
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("GeneralSettings"),
                title: "General",
                toolbarIcon: NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)!
            ) {
                GeneralPreferencesView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("Accounts"),
                title: "Accounts",
                toolbarIcon: NSImage(systemSymbolName: "at", accessibilityDescription: nil)!
            ) {
                PreferenceAccountsView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("Behaviors"),
                title: "Behaviors",
                toolbarIcon: NSImage(systemSymbolName: "flowchart", accessibilityDescription: nil)!
            ) {
                PreferencesPlaceholderView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("Navigation"),
                title: "Navigation",
                toolbarIcon: NSImage(systemSymbolName: "arrow.triangle.turn.up.right.diamond",
                                     accessibilityDescription: nil)!
            ) {
                PreferencesPlaceholderView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("Themes"),
                title: "Themes",
                toolbarIcon: NSImage(systemSymbolName: "paintbrush", accessibilityDescription: nil)!
            ) {
                ThemePreferencesView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("TextEditing"),
                title: "Text Editing",
                toolbarIcon: NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: nil)!
            ) {
                TextEditingPreferencesView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("Terminal"),
                title: "Terminal",
                toolbarIcon: NSImage(systemSymbolName: "terminal", accessibilityDescription: nil)!
            ) {
                TerminalPreferencesView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("KeyBindings"),
                title: "Key Bindings",
                toolbarIcon: NSImage(systemSymbolName: "keyboard", accessibilityDescription: nil)!
            ) {
                PreferencesPlaceholderView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("SourceControl"),
                title: "Source Control",
                toolbarIcon: NSImage.vault
            ) {
                PreferenceSourceControlView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("Components"),
                title: "Components",
                toolbarIcon: NSImage(systemSymbolName: "puzzlepiece", accessibilityDescription: nil)!
            ) {
                PreferencesPlaceholderView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("Locations"),
                title: "Locations",
                toolbarIcon: NSImage(systemSymbolName: "externaldrive", accessibilityDescription: nil)!
            ) {
                LocationsPreferencesView()
            },
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier("Advanced"),
                title: "Advanced",
                toolbarIcon: NSImage(systemSymbolName: "gearshape.2", accessibilityDescription: nil)!
            ) {
                PreferencesPlaceholderView()
            }
        ],
        animated: false
    )
}

extension AppDelegate {
    static let recoverWorkspacesKey = "recover.workspaces"
}
