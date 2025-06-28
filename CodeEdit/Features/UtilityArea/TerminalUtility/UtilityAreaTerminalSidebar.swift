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
                    let isEditing = utilityAreaViewModel.editingGroupID == group.id
                    let isGroupSelected = group.terminals.contains { utilityAreaViewModel.selectedTerminals.contains($0.id) }
                    let groupID = group.id
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 4) {
                            Image(systemName: group.isCollapsed ? "chevron.right" : "chevron.down")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)

                            GroupTitleEditor(
                                index: index,
                                group: group,
                                isEditing: isEditing,
                                viewModel: utilityAreaViewModel
                            )

                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                utilityAreaViewModel.terminalGroups[index].isCollapsed.toggle()
                            }
                        }

                        if !group.isCollapsed {
                            VStack(spacing: 0) {
                                ForEach(group.terminals, id: \.id) { terminal in
                                    VStack(spacing: 0) {
                                        if utilityAreaViewModel.dragOverTerminalID == terminal.id {
                                            InsertionIndicator()
                                        }

                                        UtilityAreaTerminalTab(
                                            terminal: terminal,
                                            removeTerminals: utilityAreaViewModel.removeTerminals,
                                            focusedTerminalID: $focusedTerminalID
                                        )
                                        .onDrag {
                                            utilityAreaViewModel.draggedTerminalID = terminal.id

                                            let dragInfo = TerminalDragInfo(terminalID: terminal.id)
                                            let provider = NSItemProvider()
                                            do {
                                                let data = try JSONEncoder().encode(dragInfo)
                                                provider.registerDataRepresentation(
                                                    forTypeIdentifier: UTType.terminal.identifier,
                                                    visibility: .all
                                                ) { completion in
                                                    completion(data, nil)
                                                    return nil
                                                }
                                            } catch {
                                                print("❌ Erro ao codificar dragInfo: \(error)")
                                            }
                                            return provider
                                        }
                                        .onDrop(of: [UTType.terminal.identifier], delegate: TerminalDropDelegate(
                                            groupID: group.id,
                                            viewModel: utilityAreaViewModel,
                                            destinationTerminalID: terminal.id
                                        ))
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                        .animation(.easeInOut(duration: 0.2), value: group.isCollapsed)
                                    }
                                }
                            }
                            .padding(.bottom, 8)
                            .onDrop(of: [UTType.terminal.identifier], delegate: TerminalDropDelegate(
                                groupID: group.id,
                                viewModel: utilityAreaViewModel,
                                destinationTerminalID: nil
                            ))
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isGroupSelected ? Color.accentColor.opacity(0.12) : Color.clear)
                    )
                    .cornerRadius(8)
                    .padding(.horizontal)
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
