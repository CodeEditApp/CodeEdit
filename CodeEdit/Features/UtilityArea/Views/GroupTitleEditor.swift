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
    @ObservedObject var viewModel: UtilityAreaViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        if isEditing {
            TextField(
                "",
                text: Binding(
                    get: {
                        viewModel.terminalGroups[safe: index]?.name ?? ""
                    },
                    set: { newValue in
                        if viewModel.terminalGroups.indices.contains(index) {
                            viewModel.terminalGroups[index].name = newValue
                        }
                    }
                ),
                onCommit: {
                    viewModel.editingGroupID = nil
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
                    viewModel.editingGroupID = nil
                }
            }
        } else {
            Text(group.name.isEmpty ? "Grupo sem nome" : group.name)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .simultaneousGesture(
                    TapGesture(count: 2).onEnded {
                        viewModel.editingGroupID = group.id
                    }
                )
        }
    }
}
