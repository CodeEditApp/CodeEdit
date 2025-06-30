//
//  UtilityAreaTerminalGroupView.swift
//  CodeEdit
//
//  Created by Gustavo Soré on 29/06/25.
//

import SwiftUI
import UniformTypeIdentifiers

/// A view that displays a terminal group with a header and a list of its terminals.
/// Supports editing the group name, collapsing, drag-and-drop, and inline terminal row management.
struct UtilityAreaTerminalGroupView: View {
    /// The index of the group within the terminalGroups array.
    let index: Int

    /// Whether this group is currently selected in the UI.
    let isGroupSelected: Bool

    /// The shared view model that manages terminal groups and their state.
    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel

    /// Manages focus on a specific terminal row for keyboard navigation or editing.
    @FocusState private var focusedTerminalID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: - Group Header

            HStack(spacing: 4) {
                Image(systemName: "square.on.square")
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.primary.opacity(0.6))

                // Editable group name when in edit mode
                if utilityAreaViewModel.editingGroupID == utilityAreaViewModel.terminalGroups[index].id {
                    TextField("", text: Binding(
                        get: { utilityAreaViewModel.terminalGroups[index].name },
                        set: { newTitle in
                            guard !newTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                            utilityAreaViewModel.terminalGroups[index].name = newTitle
                            utilityAreaViewModel.terminalGroups[index].userName = true
                        }
                    ))
                    .textFieldStyle(.plain)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.white)
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .onSubmit {
                        utilityAreaViewModel.editingGroupID = nil
                    }
                } else {
                    // Display group name normally
                    Text(
                        utilityAreaViewModel.terminalGroups[index].name.isEmpty
                            ? "terminals"
                            : utilityAreaViewModel.terminalGroups[index].name
                    )
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                        .contentShape(Rectangle())
                        .simultaneousGesture(
                            TapGesture(count: 2)
                                .onEnded {
                                    utilityAreaViewModel.editingGroupID = utilityAreaViewModel.terminalGroups[index].id
                                }
                        )
                }

                Spacer()

                // Expand/collapse toggle
                Image(
                    systemName: utilityAreaViewModel.terminalGroups[index].isCollapsed
                        ? "chevron.right"
                        : "chevron.down"
                )
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.25)) {
                    utilityAreaViewModel.terminalGroups[index].isCollapsed.toggle()
                }
            }
            .onDrag {
                // Optional: dragging the entire group (stubbed terminal ID)
                let dragInfo = TerminalDragInfo(terminalID: .init())
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
                    print("❌ Failed to encode dragInfo: \(error)")
                }
                return provider
            }

            // MARK: - Terminal Rows (if group is expanded)

            if !utilityAreaViewModel.terminalGroups[index].isCollapsed {
                VStack(spacing: 0) {
                    ForEach(utilityAreaViewModel.terminalGroups[index].terminals, id: \.id) { terminal in
                        VStack(spacing: 0) {
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
                                    groupID: utilityAreaViewModel.terminalGroups[index].id,
                                    viewModel: utilityAreaViewModel,
                                    destinationTerminalID: terminal.id
                                )
                            )
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            .animation(
                                .easeInOut(duration: 0.2),
                                value: utilityAreaViewModel.terminalGroups[index].isCollapsed
                            )
                        }
                    }
                }
                .padding(.bottom, 8)
                .padding(.leading, 16)
                .onDrop(of: [UTType.terminal.identifier], delegate: TerminalDropDelegate(
                    groupID: utilityAreaViewModel.terminalGroups[index].id,
                    viewModel: utilityAreaViewModel,
                    destinationTerminalID: focusedTerminalID
                ))
            }
        }
        .cornerRadius(8)
    }
}

// MARK: - Preview

/// Preview provider for `UtilityAreaTerminalGroupView`, showing a mock terminal group with two terminals.
struct TerminalGroupViewPreviews: PreviewProvider {
    static var previews: some View {
        let terminal = UtilityAreaTerminal(
            id: UUID(),
            url: URL(fileURLWithPath: "/mock"),
            title: "Terminal Preview",
            shell: .zsh
        )

        let terminal2 = UtilityAreaTerminal(
            id: UUID(),
            url: URL(fileURLWithPath: "/mock"),
            title: "Terminal Preview",
            shell: .zsh
        )

        let utilityAreaViewModel = UtilityAreaViewModel()
        utilityAreaViewModel.terminalGroups = [
            UtilityAreaTerminalGroup(name: "Preview Group", terminals: [terminal, terminal2])
        ]
        utilityAreaViewModel.selectedTerminals = [terminal.id]

        let tabViewModel = UtilityAreaTabViewModel()

        let workspace = WorkspaceDocument()
        workspace.setValue(URL(string: "file:///mock/path")!, forKey: "fileURL")

        return TerminalGroupViewPreviewWrapper()
            .environmentObject(utilityAreaViewModel)
            .environmentObject(tabViewModel)
            .environmentObject(workspace)
            .frame(width: 320)
    }
}

// Wrapper view to render the preview group.
private struct TerminalGroupViewPreviewWrapper: View {
    @EnvironmentObject var utilityAreaViewModel: UtilityAreaViewModel
    @FocusState private var focusedTerminalID: UUID?

    var body: some View {
        UtilityAreaTerminalGroupView(
            index: 0,
            isGroupSelected: false
        )
    }
}
