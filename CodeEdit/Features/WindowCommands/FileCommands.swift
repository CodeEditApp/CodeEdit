//
//  FileCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct FileCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Group {
                Button("New") {

                }
                .keyboardShortcut("n")
                Button("Open...") {

                }
                .keyboardShortcut("o")
                Menu("Open Recent") {
                }
                Button("Open Quickly") {

                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
            }
        }
        CommandGroup(replacing: .saveItem) {
            Button("Close Tab") {
                NSApp.sendAction(#selector(NSWindow.close), to: nil, from: nil)
            }
            .keyboardShortcut("w")
            Button("Close Editor") {

            }
            .keyboardShortcut("w", modifiers: [.control, .shift, .command])
            Button("Close Window") {

            }
            .keyboardShortcut("w", modifiers: [.shift, .command])
            Button("Close Workspace") {

            }
            .keyboardShortcut("w", modifiers: [.control, .option, .command])
            Divider()
            Button("Save") {

            }
            .keyboardShortcut("s")
        }
    }
}
