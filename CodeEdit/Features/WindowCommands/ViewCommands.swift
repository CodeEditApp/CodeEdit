//
//  ViewCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct ViewCommands: Commands {
    @AppSettings(\.textEditing.font.size)
    var editorFontSize
    @AppSettings(\.terminal.font.size)
    var terminalFontSize

    @State var windowController: CodeEditWindowController?

    private let documentController: CodeEditDocumentController = CodeEditDocumentController()
    private let statusBarViewModel: DebugAreaViewModel = DebugAreaViewModel()

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

            Button("Increase font size") {
                if !(editorFontSize >= 288) {
                    editorFontSize += 1
                }
                if !(terminalFontSize >= 288) {
                    terminalFontSize += 1
                }
            }
            .keyboardShortcut("+")
            .disabled(windowController == nil)

            Button("Decrease font size") {
                if !(editorFontSize <= 1) {
                    editorFontSize -= 1
                }
                if !(terminalFontSize <= 1) {
                    terminalFontSize -= 1
                }
            }
            .keyboardShortcut("-")
            .disabled(windowController == nil)

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
