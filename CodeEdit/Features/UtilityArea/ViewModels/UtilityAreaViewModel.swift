//
//  UtilityAreaViewModel.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 20.03.22.
//

import SwiftUI
import UniformTypeIdentifiers

/// View model responsible for managing terminal groups, individual terminals,
/// selection state, drag-and-drop operations, and utility panel configuration.
class UtilityAreaViewModel: ObservableObject {

    // MARK: - UI State

    /// Currently selected tab in the utility area.
    @Published var selectedTab: UtilityAreaTab? = .terminal

    /// Flat list of all terminals, derived from `terminalGroups`.
    @Published var terminals: [UtilityAreaTerminal] = []

    /// List of terminal groups.
    /// Automatically updates the flat `terminals` array when changed.
    @Published var terminalGroups: [UtilityAreaTerminalGroup] = [] {
        didSet {
            self.terminals = terminalGroups.flatMap { $0.terminals }
        }
    }

    /// Set of selected terminal IDs.
    @Published var selectedTerminals: Set<UUID> = []

    /// ID of the terminal currently hovered as a drop target.
    @Published var dragOverTerminalID: UUID?

    /// ID of the terminal being dragged.
    @Published var draggedTerminalID: UUID?

    /// Whether the utility area is currently collapsed.
    @Published var isCollapsed: Bool = false

    /// Whether the panel collapse/expand action should animate.
    @Published var animateCollapse: Bool = true

    /// Whether the utility area is maximized.
    @Published var isMaximized: Bool = false

    /// Current height of the utility area panel.
    @Published var currentHeight: Double = 0

    /// ID of the terminal currently being edited (e.g. for inline title editing).
    @Published var editingTerminalID: UUID?

    /// Available tabs in the utility area.
    @Published var tabItems: [UtilityAreaTab] = UtilityAreaTab.allCases

    /// View model for the current tab (e.g. terminal tab).
    @Published var tabViewModel = UtilityAreaTabViewModel()

    /// ID of the group currently being edited (e.g. renaming).
    @Published var editingGroupID: UUID?

    /// Focus state for managing terminal keyboard focus.
    @FocusState private var focusedTerminalID: UUID?

    // MARK: - Drag-and-Drop Support

    /// Previews a terminal move by temporarily updating the groups' array structure.
    func previewMoveTerminal(_ terminalID: UUID, toGroup groupID: UUID, before destinationID: UUID?) {
        guard let currentGroupIndex = terminalGroups.firstIndex(where: {
            $0.terminals.contains(where: { $0.id == terminalID })
        }),
        let currentTerminalIndex = terminalGroups[currentGroupIndex]
            .terminals.firstIndex(where: { $0.id == terminalID }) else {
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

    /// Finalizes a terminal move across or within groups, updating the actual structure.
    func finalizeMoveTerminal(_ terminal: UtilityAreaTerminal, toGroup groupID: UUID, before destinationID: UUID?) {
        let alreadyInGroup = terminalGroups.contains { group in
            group.id == groupID &&
            group.terminals.count == 1 &&
            group.terminals.first?.id == terminal.id
        }

        guard !alreadyInGroup else { return }

        // Remove terminal from all groups
        for index in terminalGroups.indices {
            terminalGroups[index].terminals.removeAll { $0.id == terminal.id }
        }

        // Remove empty groups
        terminalGroups.removeAll { $0.terminals.isEmpty }

        // Insert into new group
        guard let groupIndex = terminalGroups.firstIndex(where: { $0.id == groupID }) else { return }

        if let destinationID,
           let destinationIndex = terminalGroups[groupIndex].terminals.firstIndex(where: { $0.id == destinationID }) {
            terminalGroups[groupIndex].terminals.insert(terminal, at: destinationIndex)
        } else {
            terminalGroups[groupIndex].terminals.append(terminal)
        }

        // Update selection
        if !selectedTerminals.contains(terminal.id) {
            selectedTerminals = [terminal.id]
        }

        // Auto-name group if it wasn't named by user
        for index in terminalGroups.indices where !terminalGroups[index].userName {
            terminalGroups[index].name = "\(terminalGroups[index].terminals.count) Terminals"
        }
    }

    /// Removes a terminal from all groups by ID and returns it.
    private func removeTerminal(withID id: UUID) -> UtilityAreaTerminal? {
        for index in terminalGroups.indices {
            if let terminalIndex = terminalGroups[index].terminals.firstIndex(where: { $0.id == id }) {
                return terminalGroups[index].terminals.remove(at: terminalIndex)
            }
        }
        return nil
    }

    // MARK: - Panel State Restoration

    /// Restores panel state from the workspace object (collapsed, height, maximized).
    func restoreFromState(_ workspace: WorkspaceDocument) {
        isCollapsed = workspace.getFromWorkspaceState(.utilityAreaCollapsed) as? Bool ?? false
        currentHeight = workspace.getFromWorkspaceState(.utilityAreaHeight) as? Double ?? 300.0
        isMaximized = workspace.getFromWorkspaceState(.utilityAreaMaximized) as? Bool ?? false
    }

    /// Persists current panel state into the workspace object.
    func saveRestorationState(_ workspace: WorkspaceDocument) {
        workspace.addToWorkspaceState(key: .utilityAreaCollapsed, value: isCollapsed)
        workspace.addToWorkspaceState(key: .utilityAreaHeight, value: currentHeight)
        workspace.addToWorkspaceState(key: .utilityAreaMaximized, value: isMaximized)
    }

    /// Toggles panel collapse with optional animation.
    func togglePanel(animation: Bool = true) {
        self.animateCollapse = animation
        self.isMaximized = false
        self.isCollapsed.toggle()
    }

    // MARK: - Terminal Management

    /// Removes terminals by their IDs and updates groups and selection.
    func removeTerminals(_ ids: Set<UUID>) {
        for index in terminalGroups.indices {
            terminalGroups[index].terminals.removeAll { ids.contains($0.id) }
        }
        terminalGroups.removeAll { $0.terminals.isEmpty }

        selectedTerminals.subtract(ids)
        if selectedTerminals.isEmpty,
           let last = terminalGroups.last?.terminals.last {
            selectedTerminals = [last.id]
        }
    }

    /// Updates a terminal's title, or resets it if `nil`.
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

    /// Initializes a default terminal if none exist.
    func initializeTerminals(workspaceURL: URL) {
        guard terminalGroups.flatMap({ $0.terminals }).isEmpty else { return }
        addTerminal(rootURL: workspaceURL)
    }

    /// Adds a new terminal, optionally to a specific group and with a specific shell.
    func addTerminal(to groupID: UUID? = nil, shell: Shell? = nil, rootURL: URL?) {
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

    /// Replaces a terminal with a new instance, useful for restarting.
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

    /// Reorders terminals in the flat `terminals` list (UI only).
    func reorderTerminals(from source: IndexSet, to destination: Int) {
        terminals.move(fromOffsets: source, toOffset: destination)
    }

    /// Moves a terminal to a specific group and index.
    func moveTerminal(_ terminal: UtilityAreaTerminal, toGroup targetGroupID: UUID, at index: Int) {
        for index in terminalGroups.indices {
            terminalGroups[index].terminals.removeAll { $0.id == terminal.id }
        }
        if let idx = terminalGroups.firstIndex(where: { $0.id == targetGroupID }) {
            terminalGroups[idx].terminals.insert(terminal, at: index)
        }
    }

    /// Creates a new terminal group with the given terminals.
    func createGroup(with terminals: [UtilityAreaTerminal]) {
        terminalGroups.append(.init(name: "\(terminalGroups.count) Terminals", terminals: terminals))
    }
}
