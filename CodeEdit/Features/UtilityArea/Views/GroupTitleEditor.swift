//
//  GroupTitleEditor.swift
//  CodeEdit
//
//  Created by Gustavo Soré on 28/06/25.
//

import SwiftUI

struct GroupTitleEditor: View {
    let index: Int
    let group: UtilityAreaTerminalGroup
    let isEditing: Bool
    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        if isEditing {
            TextField(
                "",
                text: Binding(
                    get: {
                        utilityAreaViewModel.terminalGroups[safe: index]?.name ?? ""
                    },
                    set: { newValue in
                        if utilityAreaViewModel.terminalGroups.indices.contains(index) {
                            utilityAreaViewModel.terminalGroups[index].name = newValue
                        }
                    }
                ),
                onCommit: {
                    utilityAreaViewModel.editingGroupID = nil
                }
            )
            .font(.caption)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(Color.white)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .textFieldStyle(.plain)
            .frame(maxWidth: .infinity)
            .focused($isFocused)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    isFocused = true
                }
            }
            .onChange(of: isFocused) { focused in
                if !focused {
                    utilityAreaViewModel.editingGroupID = nil
                }
            }
        } else {
            Text(group.name)
                .foregroundStyle(.primary.opacity(0.7))
                .lineLimit(1)
                .font(.headline)
                .contentShape(Rectangle())
        }
    }
}

#Preview {
    GroupTitleEditorPreviewWrapper()
}

private struct GroupTitleEditorPreviewWrapper: View {
    @StateObject private var viewModel = UtilityAreaViewModel()
    @FocusState private var dummyFocus: Bool

    private let group = UtilityAreaTerminalGroup(
        id: UUID(),
        name: "Grupo de Preview",
        terminals: []
    )

    var body: some View {
        GroupTitleEditor(
            index: 0,
            group: group,
            isEditing: viewModel.editingGroupID == group.id
        )
        .environmentObject(viewModel)
        .padding()
        .frame(width: 280)
        .onAppear {
            if viewModel.terminalGroups.isEmpty {
                viewModel.terminalGroups = [group]
                viewModel.editingGroupID = nil
            }
        }
    }
}
