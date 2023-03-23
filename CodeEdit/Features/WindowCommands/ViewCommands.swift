//
//  ViewCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct ViewCommands: Commands {
    private var prefs: AppPreferencesModel = .shared
    @State var windowController: CodeEditWindowController?

    var navigatorCollapsed: Bool {
        windowController?.navigatorCollapsed ?? false
    }

    var inspectorCollapsed: Bool {
        windowController?.navigatorCollapsed ?? false
    }

    var body: some Commands {
        CommandGroup(after: .toolbar) {
            Button("Show Command Palette") {
                NSApp.sendAction(#selector(CodeEditWindowController.openCommandPalette(_:)), to: nil, from: nil)
            }
            .keyboardShortcut("p", modifiers: [.shift, .command])

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

            Divider()

            Button("\(navigatorCollapsed ? "Show" : "Hide") Navigator") {
                windowController?.toggleFirstPanel()
            }
            .disabled(windowController == nil)
            .keyboardShortcut("s", modifiers: [.control, .command])
            .onReceive(NSApp.publisher(for: \.keyWindow)) { window in
                windowController = window?.windowController as? CodeEditWindowController
            }

            Button("\(inspectorCollapsed ? "Show" : "Hide") Inspector") {
                windowController?.toggleLastPanel()
            }
            .disabled(windowController == nil)
            .keyboardShortcut("i", modifiers: [.control, .command])
        }
    }
}
