//
//  UtilityAreaTerminalTab.swift
//  CodeEdit
//
//  Created by Gustavo Soré on 28/06/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct DoubleClickableText: View {
    let text: String
    let isSelected: Bool
    let onDoubleClick: () -> Void

    var body: some View {
        Text(text.isEmpty ? "Terminal sem nome" : text)
            .lineLimit(1)
            .truncationMode(.middle)
            .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
            .foregroundColor(isSelected ? .white : .secondary)
            .contentShape(Rectangle()) // garante que clique fora do texto funcione
            .simultaneousGesture(
                TapGesture(count: 2)
                    .onEnded { onDoubleClick() }
            )
    }
}

struct UtilityAreaTerminalTab: View {
    let terminal: UtilityAreaTerminal
    let removeTerminals: (Set<UUID>) -> Void
    @FocusState.Binding var focusedTerminalID: UUID?

    @EnvironmentObject var utilityAreaViewModel: UtilityAreaViewModel
    @State private var isHovering = false

    var isSelected: Bool {
        utilityAreaViewModel.selectedTerminals.contains(terminal.id)
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: terminal.shell?.iconName ?? "terminal")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isSelected ? Color.white : Color.secondary)
                .frame(width: 20, height: 20)

            terminalTitleView()

            Spacer()

            if isHovering {
                Button {
                    removeTerminals([terminal.id])
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
        if utilityAreaViewModel.editingTerminalID == terminal.id {
            TextField("", text: Binding(
                get: { terminal.title },
                set: { newTitle in
                    guard !newTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    utilityAreaViewModel.updateTerminal(terminal.id, title: newTitle)
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
            .focused($focusedTerminalID, equals: terminal.id)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    focusedTerminalID = terminal.id
                }
            }
            .onSubmit {
                utilityAreaViewModel.editingTerminalID = nil
                focusedTerminalID = nil
            }
            .onChange(of: focusedTerminalID) { newValue in
                if newValue != terminal.id {
                    utilityAreaViewModel.editingTerminalID = nil
                }
            }
        } else {
            DoubleClickableText(
                text: terminal.title,
                isSelected: isSelected
            ) {
                utilityAreaViewModel.editingTerminalID = terminal.id
                focusedTerminalID = terminal.id
            }
        }
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
        UtilityAreaTerminalTab(
            terminal: terminal,
            removeTerminals: { _ in },
            focusedTerminalID: $focusedTerminalID
        )
        .environmentObject(viewModel)
        .environmentObject(tabViewModel)
        .environmentObject(workspace)
        .frame(width: 280)
        .padding()
    }
}
