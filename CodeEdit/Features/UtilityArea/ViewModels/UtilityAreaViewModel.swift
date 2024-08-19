//
//  UtilityAreaViewModel.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 20.03.22.
//

import SwiftUI

/// # UtilityAreaViewModel
///
/// A model class to host and manage data for the Utility area.
class UtilityAreaViewModel: ObservableObject {

    @Published var selectedTab: UtilityAreaTab? = .terminal

    @Published var terminals: [UtilityAreaTerminal] = []

    @Published var selectedTerminals: Set<UtilityAreaTerminal.ID> = []

    /// Indicates whether debugger is collapse or not
    @Published var isCollapsed: Bool = false

    /// Returns true when the drawer is visible
    @Published var isMaximized: Bool = false

    /// The current height of the drawer. Zero if hidden
    @Published var currentHeight: Double = 0

    /// The tab bar items for the UtilityAreaView
    @Published var tabItems: [UtilityAreaTab] = UtilityAreaTab.allCases

    /// The tab bar view model for UtilityAreaTabView
    @Published var tabViewModel = UtilityAreaTabViewModel()

    func removeTerminals(_ ids: Set<UUID>) {
        for (idx, terminal) in terminals.lazy.reversed().enumerated()
        where ids.contains(terminal.id) {
            TerminalCache.shared.removeCachedView(terminal.id)
            terminals.remove(at: idx)
        }

        selectedTerminals = [terminals.last?.id ?? UUID()]
    }

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

    func togglePanel() {
        self.isMaximized = false
        self.isCollapsed.toggle()
    }

    /// Update a terminal's title.
    /// - Parameters:
    ///   - id: The id of the terminal to update.
    ///   - title: The title to set. If left `nil`, will set the terminal's
    ///            ``UtilityAreaTerminal/customTitle`` to `false`.
    func updateTerminal(_ id: UUID, title: String?) {
        guard let terminal = terminals.first(where: { $0.id == id }) else { return }
        if let newTitle = title {
            if !terminal.customTitle {
                terminal.title = newTitle
            }
            terminal.terminalTitle = newTitle
        } else {
            terminal.customTitle = false
        }
    }

    /// Create a new terminal if there are no existing terminals.
    /// Will not perform any action if terminals exist in the ``terminals`` array.
    /// - Parameter workspace: The workspace to use to find the default path.
    func initializeTerminals(_ workspace: WorkspaceDocument) {
        guard terminals.isEmpty else { return }
        addTerminal(shell: nil, workspace: workspace)
    }

    /// Add a new terminal to the workspace and selects it.
    /// - Parameters:
    ///   - shell: The shell to use, `nil` if auto-detect the default shell.
    ///   - workspace: The workspace to use to find the default path.
    func addTerminal(shell: Shell? = nil, workspace: WorkspaceDocument) {
        let id = UUID()

        terminals.append(
            UtilityAreaTerminal(
                id: id,
                url: workspace.workspaceFileManager?.folderUrl ?? URL(filePath: "/"),
                title: "terminal",
                shell: shell
            )
        )

        selectedTerminals = [id]
    }
}
