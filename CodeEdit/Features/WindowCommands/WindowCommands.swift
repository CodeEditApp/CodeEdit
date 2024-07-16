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

    @State var windowController: CodeEditWindowController?

    var body: some Commands {
        CommandGroup(replacing: .singleWindowList) {
            Button("Welcome to CodeEdit") {
                openWindow(sceneID: .welcome)
            }
            .keyboardShortcut("1", modifiers: [.shift, .command])

            Button("About CodeEdit") {
                openWindow(sceneID: .about)
            }
            .keyboardShortcut("2", modifiers: [.shift, .command])

            Button("Manage Extensions") {
                openWindow(sceneID: .extensions)
            }
            .keyboardShortcut("3", modifiers: [.shift, .command])
        }

        CommandGroup(replacing: .windowArrangement) {
            Button("Show Previous Window Tab") {
                NSApp.sendAction(#selector(NSWindow.selectPreviousTab), to: nil, from: nil)
            }
            .keyboardShortcut(.tab, modifiers: [.control, .shift])
            .disabled(windowController?.window?.tabbedWindows == nil)
            .onReceive(NSApp.publisher(for: \.keyWindow)) { window in
                windowController = window?.windowController as? CodeEditWindowController
            }

            Button("Show Next Window Tab") {
                NSApp.sendAction(#selector(NSWindow.selectNextTab), to: nil, from: nil)
            }
            .keyboardShortcut(.tab, modifiers: [.control])
            .disabled(windowController?.window?.tabbedWindows == nil)
            .onReceive(NSApp.publisher(for: \.keyWindow)) { window in
                windowController = window?.windowController as? CodeEditWindowController
            }

            Button("Merge All Windows") {
                NSApp.sendAction(#selector(NSWindow.mergeAllWindows), to: nil, from: nil)
            }
            // Only enable if we have more than one document open and all the windows are not merged
            .disabled(shouldDisableMergeAll())
        }
    }

    private func shouldDisableMergeAll() -> Bool {
        // TODO: WINDOWS COUNT IS INCORRECT
        return NSApplication.shared.windows.count <= (SceneID.allCases.count + 1)
    }
}
