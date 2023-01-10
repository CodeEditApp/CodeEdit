//
//  CodeEditApp.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 03/01/2023.
//

import SwiftUI
import WindowManagement
import LanguageClient

@main
struct CodeEditApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WelcomeWindow()
            .keyboardShortcut("1", modifiers: [.command, .shift])
            .commands {
                CommandGroup(after: .appInfo) {
                    // Temporary while Settings ins't moved to Scene
                    Button("Settings...") {
                        self.appDelegate.openPreferences(self)
                    }
                    .keyboardShortcut(",")
                }
            }

        ExtensionWindow()
            .keyboardShortcut("2", modifiers: [.command, .shift])

//        WorkspaceDocumentGroup()
    }
}
