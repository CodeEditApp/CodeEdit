//
//  ViewCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct ViewCommands: Commands {

    /// The settings store, handed in by `CodeEditCommands` rather than read from the environment.
    ///
    /// `Commands` content is **not** part of the view hierarchy: `.commands { }` attaches to a
    /// `Scene` beside its content, so whether the `.environment` values `SettingsSceneInjector`
    /// applies to that content also reach here is undocumented SwiftUI behaviour. Menu items that
    /// read *and write* user settings must not rest on it — if it ever stopped holding, Font Size
    /// and the Jump Bar toggle would become silent no-ops and `DefaultSettingsReader` would trap
    /// while the menu bar is built.
    ///
    /// Observed, not merely held: the menu reflects settings state (the Jump Bar item's title, the
    /// Dim-editors check mark), so it has to re-evaluate when they change. `ObservableObject`
    /// observation inside a `Commands` conformer is already load-bearing here — it is how
    /// ``UpdatingWindowController`` keeps the Show/Hide titles below current.
    @ObservedObject private var settingsStore: AppSettingsStore

    @FocusedBinding(\.navigationSplitViewVisibility)
    var navigationSplitViewVisibility

    @FocusedBinding(\.inspectorVisibility)
    var inspectorVisibility

    @UpdatingWindowController var windowController: CodeEditWindowController?

    init(settingsStore: AppSettingsStore) {
        self.settingsStore = settingsStore
    }

    /// A fresh façade over the store. Stateless, so building one per access is free.
    private var settings: SettingsData {
        SettingsData(accessor: settingsStore)
    }

    /// The same read-modify-write `AppSettings`' `projectedValue` performs, without the environment.
    private func binding<T: Equatable>(_ keyPath: WritableKeyPath<SettingsData, T>) -> Binding<T> {
        Binding {
            settings[keyPath: keyPath]
        } set: { newValue in
            var settings = SettingsData(accessor: settingsStore)
            settings[keyPath: keyPath] = newValue
        }
    }

    /// Nudges the editor and terminal font sizes together, each clamped independently so one already
    /// at the limit does not stop the other from moving. Both bounds match the Text Editing and
    /// Terminal settings pages.
    private func adjustFontSizes(by delta: Double) {
        var settings = SettingsData(accessor: settingsStore)

        let editorSize = settings.textEditing.font.size
        if (delta > 0 && editorSize < 288) || (delta < 0 && editorSize > 1) {
            settings.textEditing.font.size = editorSize + delta
        }

        let terminalSize = settings.terminal.font.size
        if (delta > 0 && terminalSize < 288) || (delta < 0 && terminalSize > 1) {
            settings.terminal.font.size = terminalSize + delta
        }
    }

    private func resetFontSizes() {
        var settings = SettingsData(accessor: settingsStore)
        settings.textEditing.font.size = 12
        settings.terminal.font.size = 12
    }

    var body: some Commands {
        CommandGroup(after: .toolbar) {
            Button("Show Command Palette") {
                NSApp.sendAction(#selector(CodeEditWindowController.openCommandPalette(_:)), to: nil, from: nil)
            }
            .keyboardShortcut("p", modifiers: [.shift, .command])

            Button("Open Search Navigator") {
                NSApp.sendAction(#selector(CodeEditWindowController.openSearchNavigator(_:)), to: nil, from: nil)
            }
            .keyboardShortcut("f", modifiers: [.shift, .command])

            Menu("Font Size") {
                Button("Increase") {
                    adjustFontSizes(by: 1)
                }
                .keyboardShortcut("+")

                Button("Decrease") {
                    adjustFontSizes(by: -1)
                }
                .keyboardShortcut("-")

                Divider()

                Button("Reset") {
                    resetFontSizes()
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

            Button("\(settings.general.showEditorJumpBar ? "Hide" : "Show") Jump Bar") {
                var settings = SettingsData(accessor: settingsStore)
                settings.general.showEditorJumpBar.toggle()
            }

            Toggle("Dim editors without focus", isOn: binding(\.general.dimEditorsWithoutFocus))

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
            windowController?.utilityAreaModel.isCollapsed ?? true
        }

        var toolbarCollapsed: Bool {
            windowController?.toolbarCollapsed ?? true
        }

        var isInterfaceHidden: Bool {
            return windowController?.isInterfaceStillHidden() ?? false
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
                windowController?.dependencies.commandManager.executeCommand("open.drawer")
            }
            .disabled(windowController == nil)
            .keyboardShortcut("y", modifiers: [.shift, .command])

            Button("\(toolbarCollapsed ? "Show" : "Hide") Toolbar") {
                windowController?.toggleToolbar()
            }
            .disabled(windowController == nil)
            .keyboardShortcut("t", modifiers: [.option, .command])

            Button("\(isInterfaceHidden ? "Show" : "Hide") Interface") {
                windowController?.toggleInterface(shouldHide: !isInterfaceHidden)
            }
            .disabled(windowController == nil)
            .keyboardShortcut("H", modifiers: [.shift, .command])
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
