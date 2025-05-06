//
//  ViewCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI
import Combine

struct ViewCommands: Commands {
    @AppSettings(\.textEditing.font.size)
    var editorFontSize
    @AppSettings(\.terminal.font.size)
    var terminalFontSize
    @AppSettings(\.general.showEditorJumpBar)
    var showEditorJumpBar
    @AppSettings(\.general.dimEditorsWithoutFocus)
    var dimEditorsWithoutFocus

    @FocusedBinding(\.navigationSplitViewVisibility)
    var navigationSplitViewVisibility

    @FocusedBinding(\.inspectorVisibility)
    var inspectorVisibility

    @UpdatingWindowController var windowController: CodeEditWindowController?

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

            HideCommands()

            Divider()

            Button("\(showEditorJumpBar ? "Hide" : "Show") Jump Bar") {
                showEditorJumpBar.toggle()
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

extension ViewCommands {
    struct HideCommands: View {
        @UpdatingWindowController var windowController: CodeEditWindowController?

        var navigatorCollapsed: Bool {
            windowController?.navigatorCollapsed ?? true
        }

        var inspectorCollapsed: Bool {
            windowController?.inspectorCollapsed ?? true
        }

        var utilityAreaCollapsed: Bool {
            windowController?.workspace?.utilityAreaModel?.isCollapsed ?? true
        }

        var toolbarCollapsed: Bool {
            windowController?.toolbarCollapsed ?? true
        }

        var isAnythingVisible: Bool {
            !navigatorCollapsed || !inspectorCollapsed || !utilityAreaCollapsed || !toolbarCollapsed
        }

        func toggleInterface(shouldHide: Bool) {
            // When hiding, store how the interface looks now
            if shouldHide {
                storeInterfaceVisibilityState()
            }

            // Check what each elemtent state should be
            let navigatorTargetState = shouldHide ? true : (windowController?.prevNavigatorCollapsed ?? false)
            let inspectorTargetState = shouldHide ? true : (windowController?.prevInspectorCollapsed ?? false)
            let utilityAreaTargetState = shouldHide ? true : (windowController?.prevUtilityAreaCollapsed ?? false)
            let toolbarTargetState = shouldHide ? true : (windowController?.prevToolbarCollapsed ?? true)

            // Toggle only the parts that need to change
            if navigatorCollapsed != navigatorTargetState {
                windowController?.toggleFirstPanel()
            }
            if inspectorCollapsed != inspectorTargetState {
                windowController?.toggleLastPanel()
            }
            if utilityAreaCollapsed != utilityAreaTargetState {
                CommandManager.shared.executeCommand("open.drawer")
            }
            if toolbarCollapsed != toolbarTargetState {
                windowController?.toggleToolbar()
            }
        }

        func storeInterfaceVisibilityState() {
            windowController?.prevNavigatorCollapsed = navigatorCollapsed
            windowController?.prevInspectorCollapsed = inspectorCollapsed
            windowController?.prevUtilityAreaCollapsed = utilityAreaCollapsed
            windowController?.prevToolbarCollapsed = toolbarCollapsed
        }

        var body: some View {
            Button("\(navigatorCollapsed ? "Show" : "Hide") Navigator") {
                windowController?.toggleFirstPanel()
            }
            .disabled(windowController == nil)
            .keyboardShortcut("0", modifiers: [.command])

            Button("\(inspectorCollapsed ? "Show" : "Hide") Inspector") {
                windowController?.toggleLastPanel()
            }
            .disabled(windowController == nil)
            .keyboardShortcut("i", modifiers: [.control, .command])

            Button("\(utilityAreaCollapsed ? "Show" : "Hide") Utility Area") {
                CommandManager.shared.executeCommand("open.drawer")
            }
            .disabled(windowController == nil)
            .keyboardShortcut("y", modifiers: [.shift, .command])

            Button("\(toolbarCollapsed ? "Show" : "Hide") Toolbar") {
                windowController?.toggleToolbar()
            }
            .disabled(windowController == nil)
            .keyboardShortcut("t", modifiers: [.option, .command])

            Button("\(isAnythingVisible ? "Hide" : "Show") Interface") {
                toggleInterface(shouldHide: isAnythingVisible)
            }
            .disabled(windowController == nil)
            .keyboardShortcut("i", modifiers: [.option, .command])
        }
    }
}

extension ViewCommands {
    struct NavigatorCommands: View {
        @ObservedObject var model: NavigatorAreaViewModel

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
