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
    var shell: String

    init(id: UUID, url: URL, title: String, shell: String) {
        self.id = id
        self.title = title
        self.url = url
        self.shell = shell
    }
}

struct DebugAreaTerminalView: View {
    @AppSettings(\.theme.matchAppearance) private var matchAppearance
    @AppSettings(\.terminal.darkAppearance) private var darkAppearance
    @AppSettings(\.theme.useThemeBackground) private var useThemeBackground

    @Environment(\.colorScheme)
    private var colorScheme

    @EnvironmentObject
    private var workspace: WorkspaceDocument

    @EnvironmentObject
    private var model: DebugAreaViewModel

    @State
    private var sidebarIsCollapsed = false

    @StateObject
    private var themeModel: ThemeModel = .shared

    @State
    var terminals: [DebugAreaTerminal] = []

    @State
    private var selectedIDs: Set<UUID> = [UUID()]

    @State
    private var isMenuVisible = false

    @State
    private var popoverSource: CGRect = .zero

    private func initializeTerminals() {
        let id = UUID()

        terminals = [
            DebugAreaTerminal(
                id: id,
                url: workspace.workspaceFileManager?.folderUrl ?? URL(filePath: "/"),
                title: "terminal",
                shell: ""
            )
        ]

        selectedIDs = [id]
    }

    private func addTerminal(shell: String? = nil) {
        let id = UUID()

        terminals.append(
            DebugAreaTerminal(
                id: id,
                url: URL(filePath: "\(id)"),
                title: "terminal",
                shell: shell ?? ""
            )
        )

        selectedIDs = [id]
    }

    private func removeTerminals(_ ids: Set<UUID>) {
        terminals.removeAll(where: { terminal in
            ids.contains(terminal.id)
        })

        selectedIDs = [terminals.last?.id ?? UUID()]
    }

    private func getTerminal(_ id: UUID) -> DebugAreaTerminal? {
        return terminals.first(where: { $0.id == id }) ?? nil
    }

    private func updateTerminal(_ id: UUID, title: String? = nil) {
        let terminalIndex = terminals.firstIndex(where: { $0.id == id })
        if terminalIndex != nil {
            updateTerminalByReference(of: &terminals[terminalIndex!], title: title)
        }
    }

    func updateTerminalByReference(
        of terminal: inout DebugAreaTerminal,
        title: String? = nil
    ) {
        if let newTitle = title {
            terminal.title = newTitle
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
        terminals.move(fromOffsets: source, toOffset: destination)
    }

    var body: some View {
        DebugAreaTabView { tabState in
            ZStack {
                if selectedIDs.isEmpty {
                    Text("No Selection")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                ForEach(terminals) { terminal in
                    TerminalEmulatorView(
                        url: terminal.url!,
                        shellType: terminal.shell,
                        onTitleChange: { newTitle in
                            handleTitleChange(id: terminal.id, title: newTitle)
                        }
                    )
                    .padding(.top, 10)
                    .padding(.horizontal, 10)
                    .contentShape(Rectangle())
                    .disabled(terminal.id != selectedIDs.first)
                    .opacity(terminal.id == selectedIDs.first ? 1 : 0)
                }
            }
            .paneToolbar {
                PaneToolbarSection {
                    DebugAreaTerminalPicker(selectedIDs: $selectedIDs, terminals: terminals)
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
                if selectedIDs.isEmpty {
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
                selectedIDs.isEmpty
                    ? colorScheme
                    : matchAppearance && darkAppearance
                    ? themeModel.selectedDarkTheme?.appearance == .dark ? .dark : .light
                    : themeModel.selectedTheme?.appearance == .dark ? .dark : .light
            )
        } leadingSidebar: { _ in
            List(selection: $selectedIDs) {
                ForEach($terminals, id: \.self.id) { $terminal in
                    DebugAreaTerminalTab(
                        terminal: $terminal,
                        removeTerminals: removeTerminals,
                        isSelected: selectedIDs.contains(terminal.id),
                        selectedIDs: selectedIDs
                    )
                    .tag(terminal.id)
                }
                .onMove(perform: moveItems)
            }
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
            .onChange(of: terminals) { newValue in
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
                        removeTerminals(selectedIDs)
                    } label: {
                        Image(systemName: "minus")
                    }
                    .disabled(terminals.count <= 1)
                    .opacity(terminals.count <= 1 ? 0.5 : 1)
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
