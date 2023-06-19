//
//  FileCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct FileCommands: Commands {

    @FocusedObject var debugAreaViewModel: DebugAreaViewModel?

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Group {
                Button("New") {
                    NSDocumentController.shared.newDocument(nil)
                }
                .keyboardShortcut("n")

                Button("Open...") {
                    NSDocumentController.shared.openDocument(nil)
                }
                .keyboardShortcut("o")

                // Leave this empty, is done through a hidden API in WindowCommands/Utils/CommandsFixes.swift
                // This can't be done in SwiftUI Commands yet, as they don't support images in menu items.
                Menu("Open Recent") {}

                Button("Open Quickly") {
                    NSApp.sendAction(#selector(CodeEditWindowController.openQuickly(_:)), to: nil, from: nil)
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

            if let debugAreaViewModel {
                Button("Close Terminal") {
                    debugAreaViewModel.removeTerminals(debugAreaViewModel.selectedTerminals)
                }
                .keyboardShortcut(.delete)
            }

            Divider()

            Button("Save") {
                NSApp.sendAction(#selector(CodeEditWindowController.saveDocument(_:)), to: nil, from: nil)
            }
            .keyboardShortcut("s")
        }
    }
}
