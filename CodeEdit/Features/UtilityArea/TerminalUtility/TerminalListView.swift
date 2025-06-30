//
//  TerminalListView.swift
//  CodeEdit
//
//  Created by Gustavo Soré on 29/06/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct TerminalListView: View {
    @State var group: UtilityAreaTerminalGroup
    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel
    @FocusState.Binding var focusedTerminalID: UUID?

    var body: some View {
        VStack(spacing: 0) {
            ForEach(group.terminals, id: \.id) { terminal in
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

#Preview {
    TerminalListViewPreviewWrapper()
}

private struct TerminalListViewPreviewWrapper: View {
    @StateObject private var viewModel = UtilityAreaViewModel()
    @FocusState private var focusedTerminalID: UUID?

    private let mockGroup: UtilityAreaTerminalGroup = {
        let terminal1 = UtilityAreaTerminal(
            id: UUID(),
            url: URL(fileURLWithPath: "/Users/preview/mock1"),
            title: "Terminal 1",
            shell: .zsh
        )

        let terminal2 = UtilityAreaTerminal(
            id: UUID(),
            url: URL(fileURLWithPath: "/Users/preview/mock2"),
            title: "Terminal 2",
            shell: .zsh
        )

        return UtilityAreaTerminalGroup(
            id: UUID(),
            name: "Preview Group",
            terminals: [terminal1, terminal2]
        )
    }()

    var body: some View {
        TerminalListView(
            group: mockGroup,
            focusedTerminalID: $focusedTerminalID
        )
        .environmentObject(viewModel)
        .frame(width: 300)
    }
}
