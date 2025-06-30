//
//  UtilityAreaTerminalGroupView.swift
//  CodeEdit
//
//  Created by Gustavo Soré on 29/06/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct UtilityAreaTerminalGroupView: View {
    let index: Int
    let isGroupSelected: Bool
    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel
    @FocusState private var focusedTerminalID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {

                Image(systemName: "square.on.square")
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.primary.opacity(0.6))

                if utilityAreaViewModel.editingGroupID == utilityAreaViewModel.terminalGroups[index].id {
                    TextField("", text: Binding(
                        get: { utilityAreaViewModel.terminalGroups[index].name },
                        set: { newTitle in
                            guard !newTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                            utilityAreaViewModel.terminalGroups[index].name = newTitle
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
                    Text(utilityAreaViewModel.terminalGroups[index].name.isEmpty ? "terminals" : utilityAreaViewModel.terminalGroups[index].name)
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

                Image(systemName: utilityAreaViewModel.terminalGroups[index].isCollapsed ? "chevron.right" : "chevron.down")
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
//                            .onDrop(
//                                of: [UTType.terminal.identifier],
//                                delegate: TerminalDropDelegate(
//                                    groupID: group.id,
//                                    viewModel: utilityAreaViewModel,
//                                    destinationTerminalID: terminal.id
//                                )
//                            )
//                            .transition(.opacity.combined(with: .move(edge: .top)))
//                            .animation(.easeInOut(duration: 0.2), value: group.isCollapsed)
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
            UtilityAreaTerminalGroup(name: "Grupo de Preview", terminals: [terminal, terminal2])
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
