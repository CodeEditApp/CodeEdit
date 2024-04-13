//
//  CodeEditApp.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 11/03/2023.
//

import SwiftUI

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

            ExtensionManagerWindow()

            AboutWindow()

            SettingsWindow()
                .commands {
                    CodeEditCommands()
                }
        }
        .environment(\.settings, settings.preferences) // Add settings to each window environment
    }
}
