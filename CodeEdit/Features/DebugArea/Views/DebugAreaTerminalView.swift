//
//  DebuggerAreaTerminal.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/25/23.
//

import SwiftUI

struct DebugAreaTerminal: Identifiable {
    var id: UUID
    var url: URL?
    var title: String

    init(id: UUID, url: URL, title: String) {
        self.id = id
        self.title = title
        self.url = url
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
    private var model: StatusBarViewModel

    @StateObject
    private var themeModel: ThemeModel = .shared

    @State
    var terminals: [DebugAreaTerminal] = []

    @State
    private var searchText = ""

    @State
    private var terminalTabSelection: UUID = UUID()

    private func initializeTerminals() {
        var id = UUID()

        terminals = [
            DebugAreaTerminal(
                id: id,
                url: workspace.workspaceFileManager?.folderUrl ?? URL(filePath: "/"),
                title: "bash"
            )
        ]

        terminalTabSelection = id
    }

    private func addTerminal() {
        var id = UUID()

        terminals.append(
            DebugAreaTerminal(
                id: id,
                url: URL(filePath: "\(id)"),
                title: "bash"
            )
        )

        terminalTabSelection = id
    }

    private func removeTerminal(_ id: UUID) {
        terminals.removeAll(where: { $0.id == id })

        terminalTabSelection = terminals.last?.id ?? UUID()
    }

    private func getTerminal(_ id: UUID) -> DebugAreaTerminal? {
        return terminals.first(where: { $0.id == id }) ?? nil
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
                List(selection: $terminalTabSelection) {
                    ForEach($terminals, id: \.self.id) { $terminal in
                        DebugAreaTerminalTab(terminal: $terminal, removeTerminal: removeTerminal)
                            .tag(terminal.id)
                    }
                    .onMove(perform: moveItems)
                }
                .listStyle(.automatic)
                .accentColor(.secondary)
                .collapsable()
                .collapsed($model.debuggerSidebarIsCollapsed)
                .frame(minWidth: 200, idealWidth: 240, maxWidth: 400)
                .safeAreaInset(edge: .bottom, alignment: .leading) {
                    HStack(spacing: 0) {
                        Button {
                            addTerminal()
                        } label: {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(.icon(size: 29))
                        Button {
                            removeTerminal(terminalTabSelection)
                        } label: {
                            Image(systemName: "minus")
                        }
                        .disabled(terminals.count <= 1)
                        .opacity(terminals.count <= 1 ? 0.5 : 1)
                        .buttonStyle(.icon(size: 29))
                    }
                    .padding(.leading, 29)
                }
                VStack(spacing: 0) {
                    ZStack {
                        ForEach(terminals) { terminal in
                            TerminalEmulatorView(url: terminal.url!)
                                .padding(.top, 10)
                                .padding(.horizontal, 10)
                                .contentShape(Rectangle())
                                .disabled(terminal.id != terminalTabSelection)
                                .opacity(terminal.id == terminalTabSelection ? 1 : 0)
                        }
                    }
                    HStack(alignment: .center, spacing: 6.5) {
                        FilterTextField(title: "Filter", text: $searchText)
                            .frame(maxWidth: 175)
                            .padding(.leading, -2)
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
                    .padding(.leading, model.debuggerSidebarIsCollapsed ? 29 : 0)
                    .animation(.default, value: model.debuggerSidebarIsCollapsed)
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
                    model.debuggerSidebarIsCollapsed.toggle()
                } label: {
                    Image(systemName: "square.leadingthird.inset.filled")
                }
                .buttonStyle(.icon(isActive: !model.debuggerSidebarIsCollapsed, size: 29))
                Divider()
                    .frame(height: 12)
                Spacer()
            }
        }
        .onAppear(perform: initializeTerminals)
    }
}

struct DebugAreaTerminalTab: View {
    @Binding
    var terminal: DebugAreaTerminal

    var removeTerminal: (_ id: UUID) -> Void

    @FocusState
    private var isFocused: Bool

    var body: some View {
        Label {
            TextField("Name", text: $terminal.title)
                .focused($isFocused)
                .padding(.leading, -8)
        } icon: {
            Image(systemName: "terminal")
        }
        .contextMenu {
            Button("Rename...") {
                isFocused = true
            }
            Button("Kill Terminal") {
                removeTerminal(terminal.id)
            }
        }
    }
}
