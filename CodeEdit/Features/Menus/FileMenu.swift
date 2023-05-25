//
//  FileCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct FileMenu: Commands {
    @ObservedObject
    var commandManager: CommandManager = .shared

    init() {
        commandManager.register(
            "workspace.create.new.file",
            label: "Create New File",
            keyboardShortcut: KeyboardShortcut("n"),
            action: {
                NSDocumentController.shared.newDocument(nil)
            }
        )
        commandManager.register(
            "workspace.open.file",
            label: "Open File",
            keyboardShortcut: KeyboardShortcut("o"),
            action: {
                NSDocumentController.shared.openDocument(nil)
            }
        )
        commandManager.register(
            "workspace.open.quickly",
            label: "Open Quickly",
            keyboardShortcut: KeyboardShortcut("o", modifiers: [.command, .shift]),
            action: {
                NSApp.sendAction(#selector(CodeEditWindowController.openQuickly(_:)), to: nil, from: nil)
            }
        )
        commandManager.register(
            "workspace.close.window",
            label: "Close Window",
            keyboardShortcut: KeyboardShortcut("w", modifiers: [.shift, .command]),
            action: {
                NSApp.sendAction(#selector(NSWindow.close), to: nil, from: nil)
            }
        )
        commandManager.register(
            "workspace.close.tab",
            label: "Close Tab",
            keyboardShortcut: KeyboardShortcut("w"),
            action: {
                // close active tab
            }
        )
        commandManager.register(
            "workspace.close.editor",
            label: "Close Editor",
            keyboardShortcut: KeyboardShortcut("w", modifiers: [.control, .shift, .command]),
            action: {
                // close editor
            }
        )
        commandManager.register(
            "workspace.save.file",
            label: "Save File",
            keyboardShortcut: KeyboardShortcut("s"),
            action: {
                NSApp.sendAction(#selector(CodeEditWindowController.saveDocument(_:)), to: nil, from: nil)
            }
        )
    }

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Group {
                CommandMenuItem("workspace.create.new.file", label: "New")
                CommandMenuItem("workspace.open.file", label: "Open...")
                // Leave this empty, is done through a hidden API in WindowCommands/Utils/CommandsFixes.swift
                // This can't be done in SwiftUI Commands yet, as they don't support images in menu items.
                Menu("Open Recent") {}
                CommandMenuItem("workspace.open.file", label: "Open Quickly...")
            }
        }

        CommandGroup(replacing: .saveItem) {
            CommandMenuItem("workspace.close.tab", label: "Close Tab")
            CommandMenuItem("workspace.close.editor", label: "Close Editor")
            CommandMenuItem("workspace.close.window", label: "Close Window")
            Divider()
            CommandMenuItem("workspace.save.file", label: "Save")
        }
    }
}
