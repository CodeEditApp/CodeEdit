//
//  UtilityAreaTerminalSidebar.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/19/24.
//

import SwiftUI
import UniformTypeIdentifiers

/// A single row representing a terminal within a terminal group.
/// Includes icon, title, selection handling, hover actions, and delete button.
struct UtilityAreaTerminalRowView: View {
    /// The terminal instance represented by this row.
    let terminal: UtilityAreaTerminal

    /// Focus binding used for keyboard interactions or editing.
    @FocusState.Binding var focusedTerminalID: UUID?

    /// View model that manages the terminal groups and selection state.
    @EnvironmentObject var utilityAreaViewModel: UtilityAreaViewModel

    /// Tracks whether the mouse is currently hovering this row.
    @State private var isHovering = false

    /// Computed property to check if the terminal is currently selected.
    var isSelected: Bool {
        utilityAreaViewModel.selectedTerminals.contains(terminal.id)
    }

    var body: some View {
        HStack(spacing: 8) {
            // Terminal icon
            Image(systemName: "terminal")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isSelected ? Color.white : Color.secondary)
                .frame(width: 20, height: 20)

            // Terminal title
            terminalTitleView()

            Spacer()

            // Close button shown only on hover
            if isHovering {
                Button {
                    utilityAreaViewModel.removeTerminals([terminal.id])
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 12))
                        .padding(.trailing, 4)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            // Background changes on selection or drag-over
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    isSelected ? Color.blue :
                    utilityAreaViewModel.dragOverTerminalID == terminal.id ? Color.blue.opacity(0.15) : .clear
                )
        )
        .contentShape(Rectangle()) // Increases tappable area
        .onHover { hovering in
            isHovering = hovering
        }
        .simultaneousGesture(
            TapGesture(count: 1).onEnded {
                utilityAreaViewModel.selectedTerminals = [terminal.id]
            }
        )
        .animation(.easeInOut(duration: 0.15), value: isHovering)
    }

    /// Returns a view displaying the terminal's title with styling depending on selection state.
    @ViewBuilder
    private func terminalTitleView() -> some View {
        Text(terminal.title.isEmpty ? "Terminal" : terminal.title)
            .lineLimit(1)
            .truncationMode(.middle)
            .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
            .foregroundColor(isSelected ? .white : .secondary)
            .contentShape(Rectangle())
    }
}

// MARK: - Preview

/// Preview provider for `UtilityAreaTerminalRowView` with sample data.
#Preview {
    UtilityAreaTerminalTabPreviewWrapper()
}

/// Wrapper view for rendering the terminal row in Xcode Preview with mock data and environment.
private struct UtilityAreaTerminalTabPreviewWrapper: View {
    @StateObject private var viewModel = UtilityAreaViewModel()
    @StateObject private var tabViewModel = UtilityAreaTabViewModel()
    @FocusState private var focusedTerminalID: UUID?

    private let terminal = UtilityAreaTerminal(
        id: UUID(),
        url: URL(fileURLWithPath: "/mock"),
        title: "Terminal Preview",
        shell: .zsh
    )

    private let workspace: WorkspaceDocument = {
        let workspace = WorkspaceDocument()
        workspace.setValue(URL(string: "file:///mock/path")!, forKey: "fileURL")
        return workspace
    }()

    init() {
        viewModel.terminalGroups = [
            UtilityAreaTerminalGroup(name: "Preview Group", terminals: [terminal])
        ]
        viewModel.selectedTerminals = [terminal.id]
    }

    var body: some View {
        UtilityAreaTerminalRowView(
            terminal: terminal,
            focusedTerminalID: $focusedTerminalID
        )
        .environmentObject(viewModel)
        .environmentObject(tabViewModel)
        .environmentObject(workspace)
        .frame(width: 280)
        .padding()
    }
}
