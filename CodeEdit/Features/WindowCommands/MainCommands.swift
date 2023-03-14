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
                openWindow(id: "About")
            }
            
            Button("Check for updates...") {
                NSApp.sendAction(#selector(SPUStandardUpdaterController.checkForUpdates(_:)), to: nil, from: nil)
            }
        }

        CommandGroup(after: .appSettings) {
            Button("Old Settings...") {
                NSApp.sendAction(#selector(AppDelegate.openPreferences(_:)), to: nil, from: nil)
            }
            .keyboardShortcut(",", modifiers: [.command, .option, .hidden])
        }
    }
}
