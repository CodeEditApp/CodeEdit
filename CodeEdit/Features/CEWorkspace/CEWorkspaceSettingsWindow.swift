//
//  CEWorkspaceSettingsWindow.swift
//  CodeEdit
//
//  Created by Axel Martinez on 26/3/24.
//

import SwiftUI

struct CEWorkspaceSettingsWindow: Scene {
    var body: some Scene {
        Window("Workspace Settings", id: SceneID.workspaceSettings.rawValue) {
            CEWorkspaceSettingsView()
                .frame(minWidth: 715, maxWidth: 715)
                .task {
                    let window = NSApp.windows.first { $0.identifier?.rawValue == SceneID.workspaceSettings.rawValue }!
                    window.titlebarAppearsTransparent = true
                }
        }
        .windowStyle(.automatic)
        .windowToolbarStyle(.unified)
        .windowResizability(.contentSize)
    }
}
