//
//  UtilityAreaTerminalRowView.swift
//  CodeEdit
//
//  Created by Gustavo Soré on 28/06/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct UtilityAreaTerminalRowView: View {
    let terminal: UtilityAreaTerminal
    @FocusState.Binding var focusedTerminalID: UUID?

    @EnvironmentObject var utilityAreaViewModel: UtilityAreaViewModel
    @State private var isHovering = false

    var isSelected: Bool {
        utilityAreaViewModel.selectedTerminals.contains(terminal.id)
    }

    var body: some View {

        HStack(spacing: 8) {
            Image(systemName: "terminal")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isSelected ? Color.white : Color.secondary)
                .frame(width: 20, height: 20)

            terminalTitleView()

            Spacer()

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
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.blue :
                      utilityAreaViewModel.dragOverTerminalID == terminal.id ? Color.blue.opacity(0.15) : .clear)
        )
        .contentShape(Rectangle())
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

#Preview {
    UtilityAreaTerminalTabPreviewWrapper()
}

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
