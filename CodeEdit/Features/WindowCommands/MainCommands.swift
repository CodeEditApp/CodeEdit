//
//  MainCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI
import Sparkle

struct MainCommands: Commands {

    @Environment(\.openWindow) var openWindow

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button("About CodeEdit") {
                openWindow(id: SceneID.about.rawValue)
            }

            Button("Check for updates...") {
                NSApp.sendAction(#selector(SPUStandardUpdaterController.checkForUpdates(_:)), to: nil, from: nil)
            }
        }

        CommandGroup(replacing: .appSettings) {
            Button("Preferences...") {
                NSApp.sendAction(#selector(AppDelegate.openPreferences(_:)), to: nil, from: nil)
            }
            .keyboardShortcut(",")

            Button("Settings...") {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }
            .keyboardShortcut(",")
        }
    }
}
