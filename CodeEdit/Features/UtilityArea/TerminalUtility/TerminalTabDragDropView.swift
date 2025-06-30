import SwiftUI
import UniformTypeIdentifiers

struct TerminalTabDragDropView: View {
    let terminal: UtilityAreaTerminal
    let group: UtilityAreaTerminalGroup
    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel
    @FocusState.Binding var focusedTerminalID: UUID?

    var body: some View {
        UtilityAreaTerminalTab(
            terminal: terminal,
            removeTerminals: utilityAreaViewModel.removeTerminals,
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

#Preview {
    TerminalTabDragDropViewPreviewWrapper()
}

private struct TerminalTabDragDropViewPreviewWrapper: View {
    @StateObject private var viewModel = UtilityAreaViewModel()
    @StateObject private var tabViewModel = UtilityAreaTabViewModel()
    @FocusState private var focusedTerminalID: UUID?

    private var terminal: UtilityAreaTerminal {
        UtilityAreaTerminal(
            id: UUID(),
            url: URL(fileURLWithPath: "/mock"),
            title: "Terminal 1",
            shell: .zsh
        )
    }

    private var group: UtilityAreaTerminalGroup {
        UtilityAreaTerminalGroup(
            id: UUID(),
            name: "Grupo de Preview",
            terminals: [
                UtilityAreaTerminal(
                    id: UUID(),
                    url: URL(fileURLWithPath: "/mock"),
                    title: "Terminal 1",
                    shell: .zsh
                ),
                UtilityAreaTerminal(
                    id: UUID(),
                    url: URL(fileURLWithPath: "/mock"),
                    title: "Terminal 1",
                    shell: .zsh
                )
            ]
        )
    }

    var body: some View {
        TerminalTabDragDropView(
            terminal: terminal,
            group: group,
            focusedTerminalID: $focusedTerminalID
        )
        .environmentObject(viewModel)
        .environmentObject(tabViewModel)
        .environmentObject(WorkspaceDocument())
        .frame(width: 300)
    }
}
