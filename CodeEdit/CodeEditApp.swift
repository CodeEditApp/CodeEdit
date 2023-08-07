//
//  CodeEditApp.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 11/03/2023.
//

import SwiftUI
import WindowManagement

@main
struct CodeEditApp: App {
    @NSApplicationDelegateAdaptor var appdelegate: AppDelegate
    @ObservedObject var settings = Settings.shared

    @Environment(\.openWindow)
    var openWindow

    let updater: SoftwareUpdater = SoftwareUpdater()

    init() {
        _ = CodeEditDocumentController.shared
        NSMenuItem.swizzle()
        NSSplitViewItem.swizzle()
    }

    var body: some Scene {
        Group {
            WelcomeWindow()
                .keyboardShortcut("1", modifiers: [.command, .shift])

            ExtensionManagerWindow()
                .keyboardShortcut("2", modifiers: [.command, .shift])

            AboutWindow()

            SettingsWindow()

            NSDocumentGroup(for: WorkspaceDocument.self) { workspace in
                WindowSplitView(workspace: workspace)
            } defaultAction: {
                openWindow(id: SceneID.welcome.rawValue)
            }
            .register(.document(WorkspaceDocument.self)) // Required to make transition modifier work
            .transition(.documentWindow)
            .windowToolbarStyle(.unifiedCompact(showsTitle: false))
            .enableOpenWindow() // Required for opening windows through NSApp
            .handlesExternalEvents(matching: [])
            .commands {
                CodeEditCommands()
            }
        }
        .environment(\.settings, settings.preferences) // Add settings to each window environment
    }
}
