//
//  WindowCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct WindowCommands: Commands {

    @Environment(\.openWindow)
    var openWindow

    var body: some Commands {
        CommandGroup(replacing: .singleWindowList) {
            Button("Welcome to CodeEdit") {
                NSApp.openWindow(.welcome)
            }
            .keyboardShortcut("1", modifiers: [.shift, .command])

            Button("About CodeEdit") {
                NSApp.openWindow(.about)
            }
            .keyboardShortcut("2", modifiers: [.shift, .command])

            Button("Manage Extensions") {
                NSApp.openWindow(.extensions)
            }
            .keyboardShortcut("3", modifiers: [.shift, .command])
        }

        CommandGroup(after: .windowArrangement) {
            // This command is used to open SwiftUI windows from AppKit.
            // It should not be used by the user.
            // This menu item will be hidden (see WindowCommands/Utils/CommandsFixes.swift)
            Button("OpenWindowAction") {
                guard let result = NSMenuItem.openWindowAction?() else {
                    return
                }
                switch result {
                case (.some(let id), .none):
                    openWindow(id: id.rawValue)
                case (.none, .some(let data)):
                    openWindow(value: data)
                case let (.some(id), .some(data)):
                    openWindow(id: id.rawValue, value: data)
                default:
                    break
                }
            }
        }
    }
}
