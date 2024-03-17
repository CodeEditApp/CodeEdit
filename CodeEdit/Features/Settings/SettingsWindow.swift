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
        Window("Settings", id: SceneID.settings.rawValue) {
            SettingsView(updater: updater)
                .frame(minWidth: 715, maxWidth: 715)
                .task {
                    let window = NSApp.windows.first { $0.identifier?.rawValue == SceneID.settings.rawValue }!
                    window.titlebarAppearsTransparent = true
                }
        }
        .windowStyle(.automatic)
        .windowToolbarStyle(.unified)
        .windowResizability(.contentSize)
    }
}
