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
    let group: UtilityAreaTerminalGroup
    let isGroupSelected: Bool
    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel
    @FocusState private var focusedTerminalID: UUID?

    var body: some View {
        let isEditing = utilityAreaViewModel.editingGroupID == group.id

        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: group.isCollapsed ? "chevron.right" : "chevron.down")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)

                GroupTitleEditor(
                    index: index,
                    group: group,
                    isEditing: isEditing
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
                            UtilityAreaTerminalRowView(
                                terminal: terminal,
                                focusedTerminalID: $focusedTerminalID
                            )
//                            .onDrag {
//                                utilityAreaViewModel.draggedTerminalID = terminal.id
//
//                                let dragInfo = TerminalDragInfo(terminalID: terminal.id)
//                                let provider = NSItemProvider()
//                                do {
//                                    let data = try JSONEncoder().encode(dragInfo)
//                                    provider.registerDataRepresentation(
//                                        forTypeIdentifier: UTType.terminal.identifier,
//                                        visibility: .all
//                                    ) { completion in
//                                        completion(data, nil)
//                                        return nil
//                                    }
//                                } catch {
//                                    print("❌ Erro ao codificar dragInfo: \(error)")
//                                }
//                                return provider
//                            }
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
//                .onDrop(of: [UTType.terminal.identifier], delegate: TerminalDropDelegate(
//                    groupID: group.id,
//                    viewModel: utilityAreaViewModel,
//                    destinationTerminalID: focusedTerminalID
//                ))
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
            group: utilityAreaViewModel.terminalGroups[0],
            isGroupSelected: false
        )
    }
}
