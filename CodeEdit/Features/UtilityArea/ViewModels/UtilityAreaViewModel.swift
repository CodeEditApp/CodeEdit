//
//  UtilityAreaViewModel.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 20.03.22.
//

import SwiftUI

/// # UtilityAreaViewModel
///
/// A model class to host and manage data for the ``StatusBarView``
///
class UtilityAreaViewModel: ObservableObject {
    /// Returns the current location of the cursor in an editing view
    @Published var cursorLocation: CursorLocation = .init(line: 1, column: 1) // Implementation needed!!

    @Published var terminalGroups: [TerminalGroup] = []

    @Published var focusedTerminal: TerminalEmulator?

    @Published var selectedTerminals: Set<UtilityAreaTerminalSelection> = []

    /// Indicates whether debugger is collapse or not
    @Published var isCollapsed: Bool = false

    /// Returns true when the drawer is visible
    @Published var isMaximized: Bool = false

    /// The current height of the drawer. Zero if hidden
    @Published var currentHeight: Double = 0

    /// Indicates whether the drawer is being resized or not
    @Published var isDragging: Bool = false

    /// Indicates whether the breakpoint is enabled or not
    @Published var isBreakpointEnabled: Bool = true

    /// Search value to filter in drawer
    @Published var searchText: String = ""

    /// The tab bar items for the DebugAreaView
    @Published var tabItems: [UtilityAreaTab] = UtilityAreaTab.allCases

    /// The tab bar view model for UtilityAreaTabView
    @Published var tabViewModel = UtilityAreaTabViewModel()

    /// Returns the font for status bar items to use
    private(set) var toolbarFont: Font = .system(size: 11, weight: .medium)

    func removeTerminals(_ ids: some Collection<UtilityAreaTerminalSelection>) {
        let groups = ids.compactMap {
            switch $0 {
            case let .group(group): return group
            default: return nil
            }
        }
        let terminals = ids.compactMap {
            switch $0 {
            case let .terminal(terminal): return terminal
            default: return nil
            }
        }
        removeTerminals(groups)
        removeTerminals(terminals)
    }

    func removeTerminals(_ ids: some Collection<TerminalGroup>) {
        for index in terminalGroups.indices.reversed() where ids.contains(terminalGroups[index]) {
            terminalGroups.remove(at: index)
        }
    }

    func removeTerminals(_ ids: some Collection<TerminalEmulator>) {
        for terminal in ids {
            for terminalGroup in terminalGroups {
                if let index = terminalGroup.children.firstIndex(of: terminal) {
                    terminalGroup.children.remove(at: index)
                    break
                }
            }
        }
        for index in terminalGroups.indices.reversed() where terminalGroups[index].children.isEmpty {
            terminalGroups.remove(at: index)
        }
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
