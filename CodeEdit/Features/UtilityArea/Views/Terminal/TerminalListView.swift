//
//  TerminalListView.swift
//  CodeEdit
//
//  Created by Gustavo Soré on 29/06/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct TerminalListView: View {
    let group: UtilityAreaTerminalGroup
    @ObservedObject var utilityAreaViewModel: UtilityAreaViewModel
    @FocusState.Binding var focusedTerminalID: UUID?

    var body: some View {
        VStack(spacing: 0) {
            ForEach(group.terminals, id: \.id) { terminal in
                VStack(spacing: 0) {
                    TerminalTabDragDropView(
                        terminal: terminal,
                        group: group,
                        viewModel: utilityAreaViewModel,
                        focusedTerminalID: $focusedTerminalID
                    )
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
            utilityAreaViewModel: viewModel,
            focusedTerminalID: $focusedTerminalID
        )
        .environmentObject(viewModel)
        .frame(width: 300)
    }
}
