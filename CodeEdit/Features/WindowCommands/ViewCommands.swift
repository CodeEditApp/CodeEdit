//
//  ViewCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct ViewCommands: Commands {
    private var prefs: AppPreferencesModel = .shared

    var body: some Commands {
        CommandGroup(after: .toolbar) {
            Button("Show Command Palette") {
                NSApp.sendAction(#selector(CodeEditWindowController.openCommandPalette(_:)), to: nil, from: nil)
            }
            .keyboardShortcut("p")

            Button("Zoom in") {
                prefs.preferences.textEditing.font.size += 1
            }
            .keyboardShortcut("+")

            Button("Zoom out") {
                if !(prefs.preferences.textEditing.font.size <= 1) {
                    prefs.preferences.textEditing.font.size -= 1
                }
            }
            .keyboardShortcut("-")

            Button("Customize Toolbar...") {

            }
            .disabled(true)
        }
    }
}
