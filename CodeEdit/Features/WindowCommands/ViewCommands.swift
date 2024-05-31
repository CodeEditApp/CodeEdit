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
    @AppSettings(\.general.showEditorPathBar)
    var showEditorPathBar
    @AppSettings(\.general.dimEditorsWithoutFocus)
    var dimEditorsWithoutFocus

    @State private var windowController: CodeEditWindowController?

    private let documentController: CodeEditDocumentController = CodeEditDocumentController()

    @FocusedBinding(\.navigationSplitViewVisibility)
    var navigationSplitViewVisibility

    @FocusedBinding(\.inspectorVisibility)
    var inspectorVisibility

    var body: some Commands {
        CommandGroup(after: .toolbar) {
            Button("Show Command Palette") {
                NSApp.sendAction(#selector(CodeEditWindowController.openCommandPalette(_:)), to: nil, from: nil)
            }
            .keyboardShortcut("p", modifiers: [.shift, .command])

            Menu("Font Size") {
                Button("Increase") {
                    if editorFontSize < 288 {
                        editorFontSize += 1
                    }
                    if terminalFontSize < 288 {
                        terminalFontSize += 1
                    }
                }
                .keyboardShortcut("+")

                Button("Decrease") {
                    if editorFontSize > 1 {
                        editorFontSize -= 1
                    }
                    if terminalFontSize > 1 {
                        terminalFontSize -= 1
                    }
                }
                .keyboardShortcut("-")

                Divider()

                Button("Reset") {
                    editorFontSize = 12
                    terminalFontSize = 12
                }
                .keyboardShortcut("0", modifiers: [.command, .control])
            }
            .disabled(windowController == nil)

            Button("Customize Toolbar...") {

            }
            .disabled(true)

            Divider()

            HideCommands(
                windowController: windowController ?? CodeEditWindowController(window: nil, workspace: nil),
                utilityAreaModel: windowController?.workspace?.utilityAreaModel ?? UtilityAreaViewModel()
            )
                .onReceive(NSApp.publisher(for: \.keyWindow)) { window in
                    windowController = window?.windowController as? CodeEditWindowController
                }

            Divider()

            Button("\(showEditorPathBar ? "Hide" : "Show") Path Bar") {
                showEditorPathBar.toggle()
            }

            Toggle("Dim editors without focus", isOn: $dimEditorsWithoutFocus)

            Divider()

            if let model = windowController?.navigatorSidebarViewModel {
                Divider()
                NavigatorCommands(model: model)
            }
        }
    }
}

struct HideCommands: View {
    @ObservedObject var windowController: CodeEditWindowController
    @ObservedObject var utilityAreaModel: UtilityAreaViewModel

    var navigatorCollapsed: Bool {
        windowController.navigatorCollapsed
    }

    var inspectorCollapsed: Bool {
        windowController.inspectorCollapsed
    }

    var utilityAreaCollapsed: Bool {
        utilityAreaModel.isCollapsed
    }

    var toolbarCollapsed: Bool {
        windowController.toolbarCollapsed
    }

    var body: some View {
        Button("\(navigatorCollapsed ? "Show" : "Hide") Navigator") {
            windowController.toggleFirstPanel()
        }
        .disabled(windowController.window == nil)
        .keyboardShortcut("0", modifiers: [.command])

        Button("\(inspectorCollapsed ? "Show" : "Hide") Inspector") {
            windowController.toggleLastPanel()
        }
        .disabled(windowController.window == nil)
        .keyboardShortcut("i", modifiers: [.control, .command])

        Button("\(utilityAreaCollapsed ? "Show" : "Hide") Utility Area") {
            CommandManager.shared.executeCommand("open.drawer")
        }
        .disabled(windowController.window == nil)
        .keyboardShortcut("y", modifiers: [.shift, .command])

        Button("\(toolbarCollapsed ? "Show" : "Hide") Toolbar") {
            windowController.toggleToolbar()
        }
        .disabled(windowController.window == nil)
        .keyboardShortcut("t", modifiers: [.option, .command])
    }
}

extension ViewCommands {
    struct NavigatorCommands: View {
        @ObservedObject var model: NavigatorSidebarViewModel

        var body: some View {
            Menu("Navigators", content: {
                ForEach(Array(model.tabItems.prefix(9).enumerated()), id: \.element) { index, tab in
                    Button(tab.title) {
                        model.setNavigatorTab(tab: tab)
                    }
                    .keyboardShortcut(KeyEquivalent(Character(String(index + 1))))
                }
            })
        }
    }
}
