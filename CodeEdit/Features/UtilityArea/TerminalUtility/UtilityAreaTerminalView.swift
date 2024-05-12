//
//  UtilityAreaTerminal.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/25/23.
//

import SwiftUI

final class UtilityAreaTerminal: ObservableObject, Identifiable, Equatable {
    let id: UUID
    @Published var url: URL?
    @Published var title: String
    @Published var terminalTitle: String
    @Published var shell: String
    @Published var customTitle: Bool

    init(id: UUID, url: URL, title: String, shell: String) {
        self.id = id
        self.title = title
        self.terminalTitle = title
        self.url = url
        self.shell = shell
        self.customTitle = false
    }

    static func == (lhs: UtilityAreaTerminal, rhs: UtilityAreaTerminal) -> Bool {
        lhs.id == rhs.id
    }
}

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

    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel

    @State private var sidebarIsCollapsed = false

    @StateObject private var themeModel: ThemeModel = .shared

    @State private var isMenuVisible = false

    @State private var popoverSource: CGRect = .zero

    private func initializeTerminals() {
        let id = UUID()

        utilityAreaViewModel.terminals = [
            UtilityAreaTerminal(
                id: id,
                url: workspace.workspaceFileManager?.folderUrl ?? URL(filePath: "/"),
                title: "terminal",
                shell: ""
            )
        ]

        utilityAreaViewModel.selectedTerminals = [id]
    }

    private func addTerminal(shell: String? = nil) {
        let id = UUID()

        utilityAreaViewModel.terminals.append(
            UtilityAreaTerminal(
                id: id,
                url: URL(filePath: "\(id)"),
                title: "terminal",
                shell: shell ?? ""
            )
        )

        utilityAreaViewModel.selectedTerminals = [id]
    }

    private func getTerminal(_ id: UUID) -> UtilityAreaTerminal? {
        return utilityAreaViewModel.terminals.first(where: { $0.id == id }) ?? nil
    }

    private func updateTerminal(_ id: UUID, title: String? = nil) {
        let terminalIndex = utilityAreaViewModel.terminals.firstIndex(where: { $0.id == id })
        if terminalIndex != nil {
            updateTerminalByReference(of: &utilityAreaViewModel.terminals[terminalIndex!], title: title)
        }
    }

    func updateTerminalByReference(
        of terminal: inout UtilityAreaTerminal,
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
        utilityAreaViewModel.terminals.move(fromOffsets: source, toOffset: destination)
    }

    var body: some View {
        UtilityAreaTabView(model: utilityAreaViewModel.tabViewModel) { tabState in
            ZStack {
                if utilityAreaViewModel.selectedTerminals.isEmpty {
                    CEContentUnavailableView("No Selection")
                }
                ForEach(utilityAreaViewModel.terminals) { terminal in
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
                    .disabled(terminal.id != utilityAreaViewModel.selectedTerminals.first)
                    .opacity(terminal.id == utilityAreaViewModel.selectedTerminals.first ? 1 : 0)
                }
            }
            .paneToolbar {
                PaneToolbarSection {
                    UtilityAreaTerminalPicker(
                        selectedIDs: $utilityAreaViewModel.selectedTerminals,
                        terminals: utilityAreaViewModel.terminals
                    )
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
                if utilityAreaViewModel.selectedTerminals.isEmpty {
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
                utilityAreaViewModel.selectedTerminals.isEmpty
                    ? colorScheme
                    : matchAppearance && darkAppearance
                    ? themeModel.selectedDarkTheme?.appearance == .dark ? .dark : .light
                    : themeModel.selectedTheme?.appearance == .dark ? .dark : .light
            )
        } leadingSidebar: { _ in
            List(selection: $utilityAreaViewModel.selectedTerminals) {
                ForEach(utilityAreaViewModel.terminals, id: \.self.id) { terminal in
                    UtilityAreaTerminalTab(
                        terminal: terminal,
                        removeTerminals: utilityAreaViewModel.removeTerminals,
                        isSelected: utilityAreaViewModel.selectedTerminals.contains(terminal.id),
                        selectedIDs: utilityAreaViewModel.selectedTerminals
                    )
                    .tag(terminal.id)
                    .listRowSeparator(.hidden)
                }
                .onMove(perform: moveItems)
            }
            .focusedObject(utilityAreaViewModel)
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
            .onChange(of: utilityAreaViewModel.terminals) { newValue in
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
                        utilityAreaViewModel.removeTerminals(utilityAreaViewModel.selectedTerminals)
                    } label: {
                        Image(systemName: "minus")
                    }
                    .disabled(utilityAreaViewModel.terminals.count <= 1)
                    .opacity(utilityAreaViewModel.terminals.count <= 1 ? 0.5 : 1)
                }
                Spacer()
            }
        }
        .onAppear(perform: initializeTerminals)
    }
}

struct UtilityAreaTerminalPicker: View {
    @Binding var selectedIDs: Set<UUID>
    var terminals: [UtilityAreaTerminal]

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
