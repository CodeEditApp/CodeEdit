// UtilityAreaTerminalSidebar.swift
// Com ScrollView + VStack e suporte a drag & drop com preview e grupos colapsáveis

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let terminal = UTType(exportedAs: "dev.codeedit.terminal")
}

struct TerminalDragInfo: Codable {
    let terminalID: UUID
}

struct InsertionIndicator: View {
    var body: some View {
        Rectangle()
            .fill(Color.accentColor)
            .frame(height: 2)
            .padding(.horizontal, 6)
            .transition(.opacity)
    }
}

struct UtilityAreaTerminalSidebar: View {
    @EnvironmentObject private var workspace: WorkspaceDocument
    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel
    @FocusState private var focusedTerminalID: UUID?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(utilityAreaViewModel.terminalGroups.enumerated()), id: \.element.id) { index, group in
                    if group.terminals.count == 1 {
                        let terminal = group.terminals[0]
                        TerminalTabDragDropView(
                            terminal: terminal,
                            group: group,
                            viewModel: utilityAreaViewModel,
                            focusedTerminalID: $focusedTerminalID
                        )
                    } else {
                        TerminalGroupView(
                            index: index,
                            group: group,
                            isGroupSelected: true,
                            utilityAreaViewModel: utilityAreaViewModel,
                            focusedTerminalID: $focusedTerminalID
                        )
                    }
                }
            }
            .padding(.top)
        }
        .onDrop(of: [UTType.terminal.identifier], delegate: NewGroupDropDelegate(viewModel: utilityAreaViewModel))
        .background(Color(NSColor.controlBackgroundColor))
        .contextMenu {
            Button("New Terminal") {
                utilityAreaViewModel.addTerminal(rootURL: workspace.fileURL)
            }
            Menu("New Terminal With Profile") {
                Button("Default") {
                    utilityAreaViewModel.addTerminal(rootURL: workspace.fileURL)
                }
                Divider()
                ForEach(Shell.allCases, id: \.self) { shell in
                    Button(shell.rawValue) {
                        utilityAreaViewModel.addTerminal(shell: shell, rootURL: workspace.fileURL)
                    }
                }
            }
        }
        .paneToolbar {
            PaneToolbarSection {
                Button {
                    utilityAreaViewModel.addTerminal(rootURL: workspace.fileURL)
                } label: {
                    Image(systemName: "plus")
                }
                Button {
                    utilityAreaViewModel.removeTerminals(utilityAreaViewModel.selectedTerminals)
                } label: {
                    Image(systemName: "minus")
                }
                .disabled(utilityAreaViewModel.terminalGroups.flatMap { $0.terminals }.count <= 1)
                .opacity(utilityAreaViewModel.terminalGroups.flatMap { $0.terminals }.count <= 1 ? 0.5 : 1)
            }
            Spacer()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Terminals")
        .background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedTerminalID = nil
                }
        )
    }
}

struct UtilityAreaTerminalSidebar_Previews: PreviewProvider {
    static var previews: some View {
        let terminal = UtilityAreaTerminal(
            id: UUID(),
            url: URL(string: "https://example.com")!,
            title: "Terminal 1",
            shell: .zsh
        )

        let utilityAreaViewModel = UtilityAreaViewModel()
        utilityAreaViewModel.terminalGroups = [
            UtilityAreaTerminalGroup(name: "Grupo", terminals: [terminal])
        ]
        utilityAreaViewModel.selectedTerminals = [terminal.id]

        let tabViewModel = UtilityAreaTabViewModel()

        let workspace = WorkspaceDocument()
        workspace.setValue(URL(string: "file:///mock/path")!, forKey: "fileURL")

        return UtilityAreaTerminalSidebar()
            .environmentObject(utilityAreaViewModel)
            .environmentObject(tabViewModel)
            .environmentObject(workspace)
            .frame(width: 300, height: 400)
    }
}
