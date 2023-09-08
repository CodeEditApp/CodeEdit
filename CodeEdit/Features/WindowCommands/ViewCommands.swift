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
    @AppSettings(\.featureFlags.useNewWindowingSystem)
    var useNewWindowingSystem

    @State var windowController: CodeEditWindowController?

    private let documentController: CodeEditDocumentController = CodeEditDocumentController()
    private let statusBarViewModel: DebugAreaViewModel = DebugAreaViewModel()

    @FocusedBinding(\.navigationSplitViewVisibility)
    var navigationSplitViewVisibility

    @FocusedBinding(\.inspectorVisibility)
    var inspectorVisibility

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

            if useNewWindowingSystem {
                Button("\(navigationSplitViewVisibility == .detailOnly ? "Show" : "Hide") Navigator") {
                    withAnimation(.linear(duration: .zero)) {
                        if navigationSplitViewVisibility == .all {
                            navigationSplitViewVisibility = .detailOnly
                        } else {
                            navigationSplitViewVisibility = .all
                        }
                    }
                }
                .disabled(navigationSplitViewVisibility == nil)
                .keyboardShortcut("0", modifiers: [.command])

                Button("\(inspectorVisibility == false ? "Show" : "Hide") Inspector") {
                    inspectorVisibility?.toggle()
                }
                .disabled(inspectorVisibility == nil)
                .keyboardShortcut("i", modifiers: [.control, .command])
            } else {
                Button("\(navigatorCollapsed ? "Show" : "Hide") Navigator") {
                    windowController?.toggleFirstPanel()
                }
                .disabled(windowController == nil)
                .keyboardShortcut("0", modifiers: [.command])
                .onReceive(NSApp.publisher(for: \.keyWindow)) { window in
                    windowController = window?.windowController as? CodeEditWindowController
                }

                Button("\(inspectorCollapsed ? "Show" : "Hide") Inspector") {
                    windowController?.toggleLastPanel()
                }
                .disabled(windowController == nil)
                .keyboardShortcut("i", modifiers: [.control, .command])
            }

            if let model = windowController?.navigatorSidebarViewModel {
                Divider()
                NavigatorCommands(model: model)
            }
        }
    }
}

extension ViewCommands {
    struct NavigatorCommands: View {
        @ObservedObject var model: NavigatorSidebarViewModel

        var body: some View {
            Menu("Navigators", content: {
                ForEach(Array(model.items.prefix(9).enumerated()), id: \.element) { index, tab in
                    Button(tab.title) {
                        model.setNavigatorTab(tab: tab)
                    }
                    .keyboardShortcut(KeyEquivalent(Character(String(index + 1))))
                }
            })
        }
    }
}
