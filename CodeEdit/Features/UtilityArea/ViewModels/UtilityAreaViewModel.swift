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
        terminals.removeAll(where: { terminal in
            ids.contains(terminal.id)
        })

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
        withAnimation {
            self.isCollapsed.toggle()
        }
    }
}
