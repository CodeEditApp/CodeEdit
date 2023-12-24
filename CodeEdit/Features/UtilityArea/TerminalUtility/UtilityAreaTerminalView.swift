//
//  DebuggerAreaTerminal.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/25/23.
//

import SwiftUI

struct UtilityAreaTerminalView: View {
    @AppSettings(\.theme.matchAppearance)
    private var matchAppearance
    @AppSettings(\.terminal.darkAppearance)
    private var darkAppearance
    @AppSettings(\.theme.useThemeBackground)
    private var useThemeBackground

    @Environment(\.colorScheme)
    private var colorScheme

    @EnvironmentObject private var workspace: WorkspaceDocument

    @EnvironmentObject private var model: UtilityAreaViewModel

    @State private var sidebarIsCollapsed = false

    @StateObject private var themeModel: ThemeModel = .shared

    @State private var isMenuVisible = false

    @State private var popoverSource: CGRect = .zero

    private func initializeTerminals() {
        addTerminal()
    }

    private func addTerminal(url: URL? = nil, shell: String? = nil) {
        let terminal = TerminalEmulator(
            at: url ?? workspace.workspaceFileManager?.folderUrl ?? URL(filePath: "/"),
            shell: shell
        )

        let terminalGroup = UtilityAreaTerminalGroup(children: [terminal])
        model.terminalGroups.append(terminalGroup)
        model.selectedTerminals = [terminal]
    }

    /// Returns the `background` color of the selected theme
    private var backgroundColor: NSColor {
        if let selectedTheme = matchAppearance && darkAppearance
            ? themeModel.selectedDarkTheme
            : themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return NSColor(themeModel.themes[index].terminal.background.swiftColor)
        }
        return .windowBackgroundColor
    }

    func moveItems(from source: IndexSet, to destination: Int) {
        model.terminalGroups.move(fromOffsets: source, toOffset: destination)
    }

    var body: some View {
        UtilityAreaTabView(model: model.tabViewModel) { tabState in
            ZStack {
                switch model.selectedTerminals.count {
                case 0:
                    CEContentUnavailableView("No Selection")
                case 1:
                    let group = model.terminalGroups.first { $0.children.contains(model.selectedTerminals.first!)
                    }
                    if let group {
                        UtilityAreaTerminalGroupView(group, selection: $model.selectedTerminals)
                    }
                default:
                    CEContentUnavailableView("Multiple Selection")
                }
            }
            .paneToolbar {
                PaneToolbarSection {
                    UtilityAreaTerminalPicker(selection: $model.selectedTerminals, terminalGroups: model.terminalGroups)
                        .opacity(tabState.leadingSidebarIsCollapsed ? 1 : 0)
                }
                Spacer()
                PaneToolbarSection {
                    Button {
                        // clear logs
                    } label: {
                        Image(systemName: "trash")
                    }
                    Button {
                        // split terminal
                    } label: {
                        Image(systemName: "square.split.2x1")
                    }
                }
            }
            .background {
                if model.selectedTerminals.isEmpty {
                    EffectView(.contentBackground)
                } else if useThemeBackground {
                    Color(nsColor: backgroundColor)
                } else {
                    if colorScheme == .dark {
                        EffectView(.underPageBackground)
                    } else {
                        EffectView(.contentBackground)
                    }
                }
            }
            .colorScheme(
                model.selectedTerminals.isEmpty
                    ? colorScheme
                    : matchAppearance && darkAppearance
                    ? themeModel.selectedDarkTheme?.appearance == .dark ? .dark : .light
                    : themeModel.selectedTheme?.appearance == .dark ? .dark : .light
            )
        } leadingSidebar: { _ in
            List(selection: $model.selectedTerminals) {
                ForEach(model.terminalGroups) { terminalGroup in
                    UtilityAreaTerminalTab(group: terminalGroup, onRemoveTerminal: model.removeTerminals)
                        .listRowSeparator(.hidden)
                }
                .onMove(perform: moveItems)
            }
            .focusedObject(model)
            .listStyle(.automatic)
            .accentColor(.secondary)
            .contextMenu {
                Button("New Terminal") {
                    addTerminal()
                }
                Menu("New Terminal With Profile") {
                    Button("Default") {
                        addTerminal()
                    }
                    Divider()
                    Button("Bash") {
                        addTerminal(shell: "/bin/bash")
                    }
                    Button("ZSH") {
                        addTerminal(shell: "/bin/zsh")
                    }
                }
            }
            .onChange(of: model.terminalGroups) { newValue in
                if newValue.isEmpty {
                    addTerminal()
                }
            }
            .paneToolbar {
                PaneToolbarSection {
                    Button {
                        addTerminal()
                    } label: {
                        Image(systemName: "plus")
                    }
                    Button {
                        model.removeTerminals(model.selectedTerminals)
                    } label: {
                        Image(systemName: "minus")
                    }
                    .disabled(model.terminalGroups.count <= 1)
                    .opacity(model.terminalGroups.count <= 1 ? 0.5 : 1)
                }
                Spacer()
            }
        }
        .onAppear(perform: initializeTerminals)
    }
}

private struct UtilityAreaTerminalGroupView: View {
    @ObservedObject private var group: UtilityAreaTerminalGroup
    @Binding private var selection: Set<TerminalEmulator>

    init(_ group: UtilityAreaTerminalGroup, selection: Binding<Set<TerminalEmulator>>) {
        self.group = group
        _selection = selection
    }

    var body: some View {
        HStack {
            ForEach(group.children) { terminal in
                UtilityAreaTerminalTerminalView(terminal, selection: $selection)
            }
        }
        .onAppear {
            if !group.children.contains(where: selection.contains) {
                selection = group.children.first.map { [$0] } ?? []
            }
        }
        .id(group)
    }
}

private struct UtilityAreaTerminalTerminalView: View {
    @ObservedObject var terminal: TerminalEmulator
    @Binding var selection: Set<TerminalEmulator>
    @FocusState private var isFocused: Bool

    init(_ terminal: TerminalEmulator, selection: Binding<Set<TerminalEmulator>>) {
        self.terminal = terminal
        _selection = selection
    }

    var body: some View {
        let isSelected = selection.contains(terminal)
        // SwiftTerm's underlying NSView will glitch and render outside its frame
        // you also can't click-to-focus but seems to override tap gestures
        TerminalEmulatorView(terminal)
            .clipped()
            .padding(.top, 10)
            .padding(.horizontal, 10)
            .contentShape(Rectangle())
            .opacity(isSelected ? 1 : 0.5)
    }
}

struct UtilityAreaTerminalPicker: View {
    @Binding var selection: Set<TerminalEmulator>
    var terminalGroups: [UtilityAreaTerminalGroup]

    var selectedTerminal: Binding<TerminalEmulator?> {
        Binding<TerminalEmulator?> {
            selection.first
        } set: {
            if let newValue = $0 {
                selection = [newValue]
            }
        }
    }

    var body: some View {
        Picker("Terminal Tab", selection: selectedTerminal) {
            ForEach(terminalGroups) { group in
                Section {
                    ForEach(group.children) { terminal in
                        Text(terminal.title)
                            .tag(terminal)
                    }
                } header: {
                    if group.children.count > 1 {
                        Text(group.title)
                    }
                }
            }
        }
        .labelsHidden()
        .controlSize(.small)
        .buttonStyle(.borderless)
    }
}
