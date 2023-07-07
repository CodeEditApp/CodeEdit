//
//  DebuggerAreaTerminal.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/25/23.
//

import SwiftUI

struct DebugAreaTerminal: Identifiable, Equatable {
    var id: UUID
    var url: URL?
    var title: String
    var terminalTitle: String
    var shell: String
    var customTitle: Bool

    init(id: UUID, url: URL, title: String, shell: String) {
        self.id = id
        self.title = title
        self.terminalTitle = title
        self.url = url
        self.shell = shell
        self.customTitle = false
    }
}

struct DebugAreaTerminalView: View {
    @AppSettings(\.theme.matchAppearance)
    private var matchAppearance
    @AppSettings(\.terminal.darkAppearance)
    private var darkAppearance
    @AppSettings(\.theme.useThemeBackground)
    private var useThemeBackground

    @Environment(\.colorScheme)
    private var colorScheme

    @EnvironmentObject private var workspace: WorkspaceDocument

    @EnvironmentObject private var model: DebugAreaViewModel

    @State private var sidebarIsCollapsed = false

    @StateObject private var themeModel: ThemeModel = .shared

    @State private var isMenuVisible = false

    @State private var popoverSource: CGRect = .zero

    private func initializeTerminals() {
        let id = UUID()

        model.terminals = [
            DebugAreaTerminal(
                id: id,
                url: workspace.workspaceFileManager?.folderUrl ?? URL(filePath: "/"),
                title: "terminal",
                shell: ""
            )
        ]

        model.selectedTerminals = [id]
    }

    private func addTerminal(shell: String? = nil) {
        let id = UUID()

        model.terminals.append(
            DebugAreaTerminal(
                id: id,
                url: URL(filePath: "\(id)"),
                title: "terminal",
                shell: shell ?? ""
            )
        )

        model.selectedTerminals = [id]
    }

    private func getTerminal(_ id: UUID) -> DebugAreaTerminal? {
        return model.terminals.first(where: { $0.id == id }) ?? nil
    }

    private func updateTerminal(_ id: UUID, title: String? = nil) {
        let terminalIndex = model.terminals.firstIndex(where: { $0.id == id })
        if terminalIndex != nil {
            updateTerminalByReference(of: &model.terminals[terminalIndex!], title: title)
        }
    }

    func updateTerminalByReference(
        of terminal: inout DebugAreaTerminal,
        title: String? = nil
    ) {
        if let newTitle = title {
            if !terminal.customTitle {
                terminal.title = newTitle
            }
            terminal.terminalTitle = newTitle
        }
    }

    func handleTitleChange(id: UUID, title: String) {
        updateTerminal(id, title: title)
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
        model.terminals.move(fromOffsets: source, toOffset: destination)
    }

    var body: some View {
        DebugAreaTabView { tabState in
            ZStack {
                if model.selectedTerminals.isEmpty {
                    Text("No Selection")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                ForEach(model.terminals) { terminal in
                    TerminalEmulatorView(
                        url: terminal.url!,
                        shellType: terminal.shell,
                        onTitleChange: { newTitle in
                            // This can be called whenever, even in a view update so it needs to be dispatched.
                            DispatchQueue.main.async {
                                handleTitleChange(id: terminal.id, title: newTitle)
                            }
                        }
                    )
                    .padding(.top, 10)
                    .padding(.horizontal, 10)
                    .contentShape(Rectangle())
                    .disabled(terminal.id != model.selectedTerminals.first)
                    .opacity(terminal.id == model.selectedTerminals.first ? 1 : 0)
                }
            }
            .paneToolbar {
                PaneToolbarSection {
                    DebugAreaTerminalPicker(selectedIDs: $model.selectedTerminals, terminals: model.terminals)
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
                ForEach($model.terminals, id: \.self.id) { $terminal in
                    DebugAreaTerminalTab(
                        terminal: $terminal,
                        removeTerminals: model.removeTerminals,
                        isSelected: model.selectedTerminals.contains(terminal.id),
                        selectedIDs: model.selectedTerminals
                    )
                    .tag(terminal.id)
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
            .onChange(of: model.terminals) { newValue in
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
                    .disabled(model.terminals.count <= 1)
                    .opacity(model.terminals.count <= 1 ? 0.5 : 1)
                }
                Spacer()
            }
        }
        .onAppear(perform: initializeTerminals)
    }
}

struct DebugAreaTerminalPicker: View {
    @Binding var selectedIDs: Set<UUID>
    var terminals: [DebugAreaTerminal]

    var selectedID: Binding<UUID?> {
        Binding<UUID?>(
            get: {
                selectedIDs.first
            },
            set: { newValue in
                if let selectedID = newValue {
                    selectedIDs = [selectedID]
                }
            }
        )
    }

    var body: some View {
        Picker("Terminal Tab", selection: selectedID) {
            ForEach(terminals, id: \.self.id) { terminal in
                Text(terminal.title)
                    .tag(terminal.id as UUID?)
            }
        }
        .labelsHidden()
        .controlSize(.small)
        .buttonStyle(.borderless)
    }
}
