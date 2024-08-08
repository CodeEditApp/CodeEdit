//
//  UtilityAreaTerminal.swift
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

    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel

    @State private var sidebarIsCollapsed = false

    @StateObject private var themeModel: ThemeModel = .shared

    @State private var isMenuVisible = false

    @State private var popoverSource: CGRect = .zero

    private func getTerminal(_ id: UUID) -> UtilityAreaTerminal? {
        return utilityAreaViewModel.terminals.first(where: { $0.id == id }) ?? nil
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

    /// Reorders terminals in the ``utilityAreaViewModel``.
    /// - Parameters:
    ///   - source: The source indices.
    ///   - destination: The destination indices.
    private func moveItems(from source: IndexSet, to destination: Int) {
        utilityAreaViewModel.terminals.move(fromOffsets: source, toOffset: destination)
    }

    /// Finds the selected terminal.
    /// - Returns: The selected terminal.
    private func getSelectedTerminal() -> UtilityAreaTerminal? {
        guard let selectedTerminalID = utilityAreaViewModel.selectedTerminals.first else {
            return nil
        }
        return utilityAreaViewModel.terminals.first(where: { $0.id == selectedTerminalID })
    }

    var body: some View {
        UtilityAreaTabView(model: utilityAreaViewModel.tabViewModel) { tabState in
            Group {
                if let selectedTerminal = getSelectedTerminal() {
                    TerminalEmulatorView(
                        url: selectedTerminal.url,
                        terminalID: selectedTerminal.id,
                        shellType: selectedTerminal.shell,
                        onTitleChange: { [weak selectedTerminal] newTitle in
                            guard let id = selectedTerminal?.id else { return }
                            // This can be called whenever, even in a view update so it needs to be dispatched.
                            DispatchQueue.main.async { [weak utilityAreaViewModel] in
                                utilityAreaViewModel?.updateTerminal(id, title: newTitle)
                            }
                        }
                    )
                    .id(selectedTerminal.id)
                    .padding(.top, 10)
                    .padding(.horizontal, 10)
                    .contentShape(Rectangle())
                } else {
                    CEContentUnavailableView("No Selection")
                }
            }
            .paneToolbar(showDivider: true) {
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
                        guard let id = getSelectedTerminal()?.id else { return }
                        TerminalCache.shared.getTerminalView(id)?.getTerminal().resetToInitialState()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .help("Reset the terminal")
                    .disabled(getSelectedTerminal() == nil)
                    Button {
                        // split terminal
                    } label: {
                        Image(systemName: "square.split.2x1")
                    }
                    .help("Implementation Needed")
                    .disabled(true)
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
                    utilityAreaViewModel.addTerminal(workspace: workspace)
                }
                Menu("New Terminal With Profile") {
                    Button("Default") {
                        utilityAreaViewModel.addTerminal(workspace: workspace)
                    }
                    Divider()
                    ForEach(Shell.allCases, id: \.self) { shell in
                        Button(shell.rawValue) {
                            utilityAreaViewModel.addTerminal(shell: shell, workspace: workspace)
                        }
                    }
                }
            }
            .onChange(of: utilityAreaViewModel.terminals) { newValue in
                if newValue.isEmpty {
                    utilityAreaViewModel.addTerminal(workspace: workspace)
                }
            }
            .paneToolbar {
                PaneToolbarSection {
                    Button {
                        utilityAreaViewModel.addTerminal(workspace: workspace)
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
        .onAppear {
            utilityAreaViewModel.initializeTerminals(workspace)
        }
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
