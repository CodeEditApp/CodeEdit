// UtilityAreaViewModel.swift
// Atualizado para suportar drag-and-drop com reordenação visual e final com ScrollView + VStack

import SwiftUI
import UniformTypeIdentifiers

struct UtilityAreaTerminalGroup: Identifiable, Hashable {
    var id = UUID()
    var name: String = "Grupo"
    var terminals: [UtilityAreaTerminal] = []
    var isCollapsed: Bool = false
    var userName: Bool = false

    static func == (lhs: UtilityAreaTerminalGroup, rhs: UtilityAreaTerminalGroup) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// # UtilityAreaViewModel
/// A model class to host and manage data for the Utility area.
class UtilityAreaViewModel: ObservableObject {

    @Published var selectedTab: UtilityAreaTab? = .terminal

    @Published var terminals: [UtilityAreaTerminal] = []
    @Published var terminalGroups: [UtilityAreaTerminalGroup] = [] {
        didSet {
            self.terminals = terminalGroups.flatMap { $0.terminals }
        }
    }

    @Published var selectedTerminals: Set<UUID> = []
    @Published var dragOverTerminalID: UUID? = nil
    @Published var draggedTerminalID: UUID? = nil
    @Published var isCollapsed: Bool = false
    @Published var animateCollapse: Bool = true
    @Published var isMaximized: Bool = false
    @Published var currentHeight: Double = 0
    @Published var editingTerminalID: UUID? = nil
    @Published var tabItems: [UtilityAreaTab] = UtilityAreaTab.allCases
    @Published var tabViewModel = UtilityAreaTabViewModel()
    @Published var editingGroupID: UUID? = nil
    @FocusState private var focusedTerminalID: UUID?
    // MARK: - Drag Support

    func previewMoveTerminal(_ terminalID: UUID, toGroup groupID: UUID, before destinationID: UUID?) {
        guard let currentGroupIndex = terminalGroups.firstIndex(where: { $0.terminals.contains(where: { $0.id == terminalID }) }),
              let currentTerminalIndex = terminalGroups[currentGroupIndex].terminals.firstIndex(where: { $0.id == terminalID }) else {
            return
        }

        let currentGroupID = terminalGroups[currentGroupIndex].id
        if currentGroupID == groupID,
           let destID = destinationID,
           terminalGroups[currentGroupIndex].terminals.firstIndex(where: { $0.id == destID }) == currentTerminalIndex {
            return
        }

        let terminal = terminalGroups[currentGroupIndex].terminals[currentTerminalIndex]
        terminalGroups[currentGroupIndex].terminals.remove(at: currentTerminalIndex)
        terminalGroups[currentGroupIndex].terminals = terminalGroups[currentGroupIndex].terminals

        if let targetIndex = terminalGroups.firstIndex(where: { $0.id == groupID }) {
            var group = terminalGroups[targetIndex]

            if let destID = destinationID,
               let destIndex = group.terminals.firstIndex(where: { $0.id == destID }) {
                group.terminals.insert(terminal, at: destIndex)
            } else {
                group.terminals.append(terminal)
            }

            terminalGroups[targetIndex] = group
        }
    }

    func finalizeMoveTerminal(_ terminal: UtilityAreaTerminal, toGroup groupID: UUID, before destinationID: UUID?) {

        print("finalizeMoveTerminal")

        let alreadyInGroup = terminalGroups.contains { group in
            group.id == groupID &&
            group.terminals.count == 1 &&
            group.terminals.first?.id == terminal.id
        }

        guard !alreadyInGroup else { return }

        for index in terminalGroups.indices {
            terminalGroups[index].terminals.removeAll { $0.id == terminal.id }
        }

        // Remove grupos vazios após a remoção
        terminalGroups.removeAll { $0.terminals.isEmpty }

        // Adiciona ao grupo destino
        guard let groupIndex = terminalGroups.firstIndex(where: { $0.id == groupID }) else {
            print("⚠️ Grupo não encontrado para o drop.")
            return
        }

        if let destinationID,
           let destinationIndex = terminalGroups[groupIndex].terminals.firstIndex(where: { $0.id == destinationID }) {
            terminalGroups[groupIndex].terminals.insert(terminal, at: destinationIndex)
        } else {
            terminalGroups[groupIndex].terminals.append(terminal)
        }

        // Atualiza seleção
        if !selectedTerminals.contains(terminal.id) {
            selectedTerminals = [terminal.id]
        }

        for index in terminalGroups.indices {
            if !terminalGroups[index].userName {
                terminalGroups[index].name = "\(terminalGroups[index].terminals.count) Terminals"
            }
        }
    }

    private func removeTerminal(withID id: UUID) -> UtilityAreaTerminal? {
        for index in terminalGroups.indices {
            if let terminalIndex = terminalGroups[index].terminals.firstIndex(where: { $0.id == id }) {
                return terminalGroups[index].terminals.remove(at: terminalIndex)
            }
        }
        return nil
    }

    // MARK: - State Restoration

    func restoreFromState(_ workspace: WorkspaceDocument) {
        isCollapsed = workspace.getFromWorkspaceState(.utilityAreaCollapsed) as? Bool ?? false
        currentHeight = workspace.getFromWorkspaceState(.utilityAreaHeight) as? Double ?? 300.0
        isMaximized = workspace.getFromWorkspaceState(.utilityAreaMaximized) as? Bool ?? false
    }

    func saveRestorationState(_ workspace: WorkspaceDocument) {
        workspace.addToWorkspaceState(key: .utilityAreaCollapsed, value: isCollapsed)
        workspace.addToWorkspaceState(key: .utilityAreaHeight, value: currentHeight)
        workspace.addToWorkspaceState(key: .utilityAreaMaximized, value: isMaximized)
    }

    func togglePanel(animation: Bool = true) {
        self.animateCollapse = animation
        self.isMaximized = false
        self.isCollapsed.toggle()
    }

    // MARK: - Terminal Management

    func removeTerminals(_ ids: Set<UUID>) {
        for index in terminalGroups.indices {
            terminalGroups[index].terminals.removeAll { ids.contains($0.id) }
        }

        // Remove grupos vazios
        terminalGroups.removeAll { $0.terminals.isEmpty }

        // Atualiza seleção
        selectedTerminals.subtract(ids)
        if selectedTerminals.isEmpty,
           let last = terminalGroups.last?.terminals.last {
            selectedTerminals = [last.id]
        }
    }

    func updateTerminal(_ id: UUID, title: String?) {
        for index in terminalGroups.indices {
            if let terminalIndex = terminalGroups[index].terminals.firstIndex(where: { $0.id == id }) {
                if let newTitle = title {
                    terminalGroups[index].terminals[terminalIndex].title = newTitle
                } else {
                    terminalGroups[index].terminals[terminalIndex].customTitle = false
                }
                break
            }
        }
    }

    func initializeTerminals(workspaceURL: URL) {
        guard terminalGroups.flatMap({ $0.terminals }).isEmpty else { return }
        addTerminal(rootURL: workspaceURL)
    }

    func addTerminal(to groupID: UUID? = nil, shell: Shell? = nil, rootURL: URL?) {
        
        print("Did add temrinal")
        
        let newTerminal = UtilityAreaTerminal(
            id: UUID(),
            url: rootURL ?? URL(filePath: "~/"),
            title: shell?.rawValue ?? "terminal",
            shell: shell
        )

        if let groupID, let index = terminalGroups.firstIndex(where: { $0.id == groupID }) {
            terminalGroups[index].terminals.append(newTerminal)
            terminalGroups[index].name = "\(terminalGroups[index].terminals.count) Terminals"
        } else {
            terminalGroups.append(.init(name: "2 Terminals", terminals: [newTerminal]))
        }

        selectedTerminals = [newTerminal.id]
    }

    func replaceTerminal(_ replacing: UUID) {
        for index in terminalGroups.indices {
            if let idx = terminalGroups[index].terminals.firstIndex(where: { $0.id == replacing }) {
                let url = terminalGroups[index].terminals[idx].url
                let shell = terminalGroups[index].terminals[idx].shell
                if let shellPid = TerminalCache.shared.getTerminalView(replacing)?.process.shellPid {
                    kill(shellPid, SIGKILL)
                }
                let newTerminal = UtilityAreaTerminal(
                    id: UUID(),
                    url: url,
                    title: shell?.rawValue ?? "terminal",
                    shell: shell
                )
                terminalGroups[index].terminals[idx] = newTerminal
                TerminalCache.shared.removeCachedView(replacing)
                selectedTerminals = [newTerminal.id]
                break
            }
        }
    }

    func reorderTerminals(from source: IndexSet, to destination: Int) {
        terminals.move(fromOffsets: source, toOffset: destination)
    }

    func moveTerminal(_ terminal: UtilityAreaTerminal, toGroup targetGroupID: UUID, at index: Int) {
        for index in terminalGroups.indices {
            terminalGroups[index].terminals.removeAll { $0.id == terminal.id }
        }
        if let idx = terminalGroups.firstIndex(where: { $0.id == targetGroupID }) {
            terminalGroups[idx].terminals.insert(terminal, at: index)
        }
    }

    func createGroup(with terminals: [UtilityAreaTerminal]) {
        terminalGroups.append(.init(name: "\(terminalGroups.count) Terminals", terminals: terminals))
    }
}

struct TerminalDropDelegate: DropDelegate {
    let groupID: UUID
    let viewModel: UtilityAreaViewModel
    let destinationTerminalID: UUID?

    func validateDrop(info: DropInfo) -> Bool {
        info.hasItemsConforming(to: [UTType.terminal.identifier])
    }

    func dropEntered(info: DropInfo) {
        guard let item = info.itemProviders(for: [UTType.terminal.identifier]).first else { return }

        item.loadDataRepresentation(forTypeIdentifier: UTType.terminal.identifier) { data, _ in
            guard let data = data,
                  let dragInfo = try? JSONDecoder().decode(TerminalDragInfo.self, from: data) else { return }

            DispatchQueue.main.async {
                withAnimation {
                    viewModel.draggedTerminalID = dragInfo.terminalID
                    viewModel.dragOverTerminalID = destinationTerminalID
                }
            }
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.dragOverTerminalID = destinationTerminalID
            }
        }

        return .init(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let item = info.itemProviders(for: [UTType.terminal.identifier]).first else { return false }

        item.loadDataRepresentation(forTypeIdentifier: UTType.terminal.identifier) { data, _ in
            guard let data = data,
                  let dragInfo = try? JSONDecoder().decode(TerminalDragInfo.self, from: data),
                  let terminal = viewModel.terminalGroups.flatMap({
                      $0.terminals
                  }).first( where: {
                        $0.id == dragInfo.terminalID
                  }) else { return }

            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.finalizeMoveTerminal(terminal, toGroup: groupID, before: destinationTerminalID)
                    viewModel.dragOverTerminalID = nil
                    viewModel.draggedTerminalID = nil
                }
            }
        }
        return true
    }
}

struct NewGroupDropDelegate: DropDelegate {
    let viewModel: UtilityAreaViewModel

    func validateDrop(info: DropInfo) -> Bool {
        info.hasItemsConforming(to: [UTType.terminal.identifier])
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let item = info.itemProviders(for: [UTType.terminal.identifier]).first else { return false }

        item.loadDataRepresentation(forTypeIdentifier: UTType.terminal.identifier) { data, _ in
            guard let data = data,
                  let dragInfo = try? JSONDecoder().decode(TerminalDragInfo.self, from: data),
                  let terminal = viewModel.terminalGroups.flatMap({ $0.terminals }).first(where: { $0.id == dragInfo.terminalID }) else {
                return
            }

            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.finalizeMoveTerminal(terminal, toGroup: UUID(), before: nil)
                    viewModel.createGroup(with: [terminal])
                    viewModel.dragOverTerminalID = nil
                    viewModel.draggedTerminalID = nil
                }
            }
        }
        return true
    }
}
