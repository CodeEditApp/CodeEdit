//
//  ViewCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct ViewCommands: Commands {
    @AppSettings(\.textEditing.font) var font

    @State var windowController: CodeEditWindowController?

    private let documentController: CodeEditDocumentController = CodeEditDocumentController()
    private let statusBarViewModel: StatusBarViewModel = StatusBarViewModel()

    var navigatorCollapsed: Bool {
        windowController?.navigatorCollapsed ?? false
    }

    var inspectorCollapsed: Bool {
        windowController?.navigatorCollapsed ?? false
    }

    var body: some Commands {
        CommandGroup(after: .toolbar) {
            Button("Show Commands Overlay") {
                NSApp.sendAction(#selector(CodeEditWindowController.openCommandsOverlay(_:)), to: nil, from: nil)
            }
            .keyboardShortcut("k")

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
