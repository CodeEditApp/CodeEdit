//
//  UtilityAreaTerminalSidebar.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/19/24.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - UTType Extension

/// Custom type identifier used for drag-and-drop functionality involving terminal items.
extension UTType {
    static let terminal = UTType(exportedAs: "dev.codeedit.terminal")
}

// MARK: - TerminalDragInfo

/// Represents the information used when dragging a terminal in the sidebar.
struct TerminalDragInfo: Codable {
    let terminalID: UUID
}

// MARK: - UtilityAreaTerminalSidebar

/// A SwiftUI view that displays the list of available terminals in the utility area.
/// Supports single terminal rows, terminal groups, drag and drop functionality,
/// context menus for creating terminals, and a custom toolbar.
struct UtilityAreaTerminalSidebar: View {
    /// The current workspace document environment object.
    @EnvironmentObject private var workspace: WorkspaceDocument

    /// The view model that manages terminal groups and terminals in the utility area.
    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel

    /// Focus state for determining which terminal (if any) is currently focused.
    @FocusState private var focusedTerminalID: UUID?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Iterate over terminal groups to display each accordingly
                ForEach(Array(utilityAreaViewModel.terminalGroups.enumerated()), id: \.element.id) { index, group in
                    if group.terminals.count == 1 {
                        let terminal = group.terminals[0]
                        UtilityAreaTerminalRowView(
                            terminal: terminal,
                            focusedTerminalID: $focusedTerminalID
                        )
                        .onDrag {
                            utilityAreaViewModel.draggedTerminalID = terminal.id

                            let dragInfo = TerminalDragInfo(terminalID: terminal.id)
                            let provider = NSItemProvider()
                            guard let data = try? JSONEncoder().encode(dragInfo) else {
                                return provider
                            }
                            provider.registerDataRepresentation(
                                forTypeIdentifier: UTType.terminal.identifier,
                                visibility: .all
                            ) { completion in
                                completion(data, nil)
                                return nil
                            }
                            return provider
                        }
                        .onDrop(
                            of: [UTType.terminal.identifier],
                            delegate: TerminalDropDelegate(
                                groupID: group.id,
                                viewModel: utilityAreaViewModel,
                                destinationTerminalID: terminal.id
                            )
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .animation(.easeInOut(duration: 0.2), value: group.isCollapsed)
                    } else {
                        // Display a terminal group with collapsible behavior
                        UtilityAreaTerminalGroupView(
                            index: index,
                            isGroupSelected: true
                        )
                    }
                }
            }
            .padding(.top)
        }
        .onDrop(
            of: [UTType.terminal.identifier],
            delegate: NewGroupDropDelegate(viewModel: utilityAreaViewModel)
        )
        .background(Color(NSColor.controlBackgroundColor))
        .contextMenu {
            // Context menu for creating new terminals
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
                // Toolbar button for adding a new terminal
                Button {
                    utilityAreaViewModel.addTerminal(rootURL: workspace.fileURL)
                } label: {
                    Image(systemName: "plus")
                }

                // Toolbar button for removing selected terminals
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

// MARK: - Preview

/// Preview provider for `UtilityAreaTerminalSidebar`.
struct UtilityAreaTerminalSidebarPreviews: PreviewProvider {
    static var previews: some View {
        // Sample terminal for preview
        let terminal = UtilityAreaTerminal(
            id: UUID(),
            url: URL(string: "https://example.com")!,
            title: "Terminal 1",
            shell: .zsh
        )

        // Mock view model with one group
        let utilityAreaViewModel = UtilityAreaViewModel()
        utilityAreaViewModel.terminalGroups = [
            UtilityAreaTerminalGroup(name: "Group", terminals: [terminal])
        ]
        utilityAreaViewModel.selectedTerminals = [terminal.id]

        // Mock tab view model and workspace
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
