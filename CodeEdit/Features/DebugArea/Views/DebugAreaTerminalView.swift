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

    private func updateTerminalTitle(_ id: UUID, _ title: String) {
        var terminal = terminals.first(where: { $0.id == id }) ?? nil

        terminal?.title = title
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
        ZStack(alignment: .bottom) {
            SplitView(axis: .horizontal) {
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
                .collapsable()
                .collapsed($sidebarIsCollapsed)
                .frame(minWidth: 200, idealWidth: 240, maxWidth: 400)
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
                .safeAreaInset(edge: .bottom, alignment: .leading) {
                    HStack(spacing: 0) {
                        Button {
                            addTerminal()
                        } label: {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(.icon(size: 29))
                        Button {
                            removeTerminals(selectedIDs)
                        } label: {
                            Image(systemName: "minus")
                        }
                        .disabled(terminals.count <= 1)
                        .opacity(terminals.count <= 1 ? 0.5 : 1)
                        .buttonStyle(.icon(size: 29))
                    }
                    .padding(.leading, 29)
                }
                ZStack {
                    if selectedIDs.isEmpty {
                        Text("No Selection")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(EffectView(.contentBackground).ignoresSafeArea())
                    }
                    ForEach(terminals) { terminal in
                        TerminalEmulatorView(url: terminal.url!, shellType: terminal.shell)
                            .padding(.top, 10)
                            .padding(.horizontal, 10)
                            .contentShape(Rectangle())
                            .disabled(terminal.id != selectedIDs.first)
                            .opacity(terminal.id == selectedIDs.first ? 1 : 0)
                    }
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    HStack(alignment: .center, spacing: 6.5) {
                        DebugAreaTerminalPicker(selectedIDs: $selectedIDs, terminals: terminals)
                        .opacity(sidebarIsCollapsed ? 1 : 0)
                        Spacer()
                        Button {
                            // clear logs
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.icon)
                        Divider()
                        HStack(alignment: .center, spacing: 3.5) {
                            Button {
                                // split terminal
                            } label: {
                                Image(systemName: "square.split.2x1")
                            }
                            .buttonStyle(.icon)
                            Button {
                                model.isMaximized.toggle()
                            } label: {
                                Image(systemName: "arrowtriangle.up.square")
                            }
                            .buttonStyle(.icon(isActive: model.isMaximized))
                        }
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 8)
                    .padding(.leading, sidebarIsCollapsed ? 29 : 0)
                    .animation(.default, value: sidebarIsCollapsed)
                    .frame(maxHeight: 28)
                }
                .holdingPriority(.init(1))
                .background {
                    if useThemeBackground {
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
                    matchAppearance && darkAppearance
                    ? themeModel.selectedDarkTheme?.appearance == .dark ? .dark : .light
                    : themeModel.selectedTheme?.appearance == .dark ? .dark : .light
                )
            }
            HStack(spacing: 0) {
                Button {
                    sidebarIsCollapsed.toggle()
                } label: {
                    Image(systemName: "square.leadingthird.inset.filled")
                }
                .buttonStyle(.icon(isActive: !sidebarIsCollapsed, size: 29))
                Divider()
                    .frame(height: 12)
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
