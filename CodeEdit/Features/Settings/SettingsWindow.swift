//
//  SettingsWindow.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/31/23.
//

import SwiftUI

struct SettingsWindow: Scene {
    private let updater = SoftwareUpdater()

    var body: some Scene {
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
    }
}

