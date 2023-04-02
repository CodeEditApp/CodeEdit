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
    let updater: SoftwareUpdater = SoftwareUpdater()

    init() {
        _ = CodeEditDocumentController.shared
        NSMenuItem.swizzle()
    }

    var body: some Scene {

        WelcomeWindow()

        AboutWindow()

        Settings {
            SettingsView(updater: updater)
            .frame(minWidth: 715, maxWidth: 715)
            .task {
                let window = NSApp.windows.first { $0.identifier?.rawValue == "com_apple_SwiftUI_Settings_window" }!
                window.toolbarStyle = .unified
                window.titlebarSeparatorStyle = .automatic

                let sidebaritem = "com.apple.SwiftUI.navigationSplitView.toggleSidebar"
                let index = window.toolbar?.items.firstIndex { $0.itemIdentifier.rawValue == sidebaritem }
                if let index {
                    window.toolbar?.removeItem(at: index)
                }
            }
        }
        .defaultSize(width: 500, height: 500)
        .commands {
            CodeEditCommands()
        }
    }
}
