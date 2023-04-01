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
        Window("Settings", id: "settings") {
            SettingsView(updater: updater)
                .frame(minWidth: 715, maxWidth: 715)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
    }
}
