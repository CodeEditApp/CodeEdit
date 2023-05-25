//
//  ViewCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct ViewMenu: Commands {
    @AppSettings(\.textEditing.font) var font

    @State var windowController: CodeEditWindowController?

    var commandManager = CommandManager.shared

    private let documentController: CodeEditDocumentController = CodeEditDocumentController()
    private let statusBarViewModel: StatusBarViewModel = StatusBarViewModel()

    var navigatorCollapsed: Bool {
        windowController?.navigatorCollapsed ?? false
    }

    var inspectorCollapsed: Bool {
        windowController?.navigatorCollapsed ?? false
    }

    var debugAreaCollapsed: Bool {
        windowController?.debugAreaCollapsed ?? true
    }

    init() {
        commandManager.register(
            "workspace.show.commands.overlay",
            label: "Show Commands Overlay",
            keyboardShortcut: KeyboardShortcut("k"),
            action: {
                NSApp.sendAction(#selector(CodeEditWindowController.openCommandsOverlay(_:)), to: nil, from: nil)
            }
        )
        commandManager.register(
            "workspace.toggle.navigator.area.visibility",
            label: "Toggle Navigator Area Visibility",
            keyboardShortcut: KeyboardShortcut("0"),
            action: windowController?.toggleFirstPanel ?? {}
        )
        commandManager.register(
            "workspace.toggle.inspector.area.visibility",
            label: "Toggle Inspector Area Visibility",
            keyboardShortcut: KeyboardShortcut("0", modifiers: [.option, .command]),
            action: windowController?.toggleLastPanel ?? {}
        )
        commandManager.register(
            "workspace.toggle.debug.area.visibility",
            label: "Toggle Debug Area Visibility",
            keyboardShortcut: KeyboardShortcut("y", modifiers: [.shift, .command]),
            action: windowController?.toggleDebugAreaVisibility ?? {}
        )
    }

    var body: some Commands {
        CommandGroup(after: .toolbar) {
            CommandMenuItem("workspace.show.commands.overlay", label: "Show Commands Overlay")

            Button("Increase font size") {
                if CodeEditDocumentController.shared.documents.count > 1 {
                    font.size += 1
                }
                font.size += 1
            }
            .keyboardShortcut("+")

            Button("Decrease font size") {
                if CodeEditDocumentController.shared.documents.count > 1 {
                    if !(font.size <= 1) {
                        font.size -= 1
                    }
                }
                if !(font.size <= 1) {
                    font.size -= 1
                }
            }
            .keyboardShortcut("-")

            Button("Customize Toolbar...") {

            }
            .disabled(true)

            Divider()

            CommandMenuItem(
                "workspace.toggle.navigator.area.visibility",
                label: "\(navigatorCollapsed ? "Show" : "Hide") Navigator"
            )
            .disabled(windowController == nil)
            .onReceive(NSApp.publisher(for: \.keyWindow)) { window in
                windowController = window?.windowController as? CodeEditWindowController
            }

            CommandMenuItem(
                "workspace.toggle.inspector.area.visibility",
                label: "\(inspectorCollapsed ? "Show" : "Hide") Inspector"
            )
            .disabled(windowController == nil)

            CommandMenuItem(
                "workspace.toggle.debug.area.visibility",
                label: "\(debugAreaCollapsed ? "Show" : "Hide") Debug Area"
            )
            .disabled(windowController == nil)
        }
    }
}
