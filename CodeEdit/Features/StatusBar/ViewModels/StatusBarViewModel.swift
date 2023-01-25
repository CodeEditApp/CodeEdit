//
//  StatusBarModel.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 20.03.22.
//

import SwiftUI

/// # StatusBarModel
///
/// A model class to host and manage data for the ``StatusBarView``
///
class StatusBarViewModel: ObservableObject {
    private let isStatusBarDrawerCollapsedStateName: String
        = "\(String(describing: StatusBarViewModel.self))-IsStatusBarDrawerCollapsed"
    private let statusBarDrawerHeightStateName: String
        = "\(String(describing: StatusBarViewModel.self))-StatusBarDrawerHeight"

    // TODO: Implement logic for updating values
    // TODO: Add @Published vars for indentation, encoding, linebreak

    /// The selected tab in the main section.
    /// - **0**: Terminal
    /// - **1**: Debugger
    /// - **2**: Output
    @Published
    var selectedTab: Int = 0

    /// Returns the current location of the cursor in an editing view
    @Published
    var cursorLocation: CursorLocation = .init(line: 1, column: 1) // Implementation needed!!

    /// Returns true when the drawer is visible
    @Published
    var isExpanded: Bool = false

    /// Returns true when the drawer is visible
    @Published
    var isMaximized: Bool = false

    /// The current height of the drawer. Zero if hidden
    @Published
    var currentHeight: Double = 0

    /// Indicates whether the drawer is beeing resized or not
    @Published
    var isDragging: Bool = false

    /// Indicates whether the breakpoint is enabled or not
    @Published
    var isBreakpointEnabled: Bool = true

    /// Search value to filter in drawer
    @Published
    var searchText: String = ""

    /// Returns the font for status bar items to use
    private(set) var toolbarFont: Font = .system(size: 11)

    private(set) var workspace: WorkspaceDocument

    /// The base URL of the workspace
    private(set) var workspaceURL: URL

    /// The maximum height of the drawer
    /// when isMaximized is true the height gets set to maxHeight
    private(set) var maxHeight: Double = 5000

    /// The default height of the drawer
    private(set) var standardHeight: Double = 300

    /// The minimum height of the drawe
    private(set) var minHeight: Double = 100

    /// Initialize with a GitClient
    /// - Parameter workspaceURL: the current workspace URL
    init(workspace: WorkspaceDocument, workspaceURL: URL) {
        self.workspace = workspace
        self.workspaceURL = workspaceURL

        var currentHeight = workspace.getFromWorkspaceState(key: statusBarDrawerHeightStateName) as? Double
                            ?? self.standardHeight
        if currentHeight == 0 {
            currentHeight = self.standardHeight
        }

        self.isExpanded = workspace.getFromWorkspaceState(key: isStatusBarDrawerCollapsedStateName) as? Bool ?? false
        if self.isExpanded {
            self.currentHeight = currentHeight
        }
    }

    func saveIsExpandedToState() {
        self.workspace.addToWorkspaceState(key: isStatusBarDrawerCollapsedStateName, value: self.isExpanded)
    }

    func saveHeightToState(height: Double) {
        self.workspace.addToWorkspaceState(key: statusBarDrawerHeightStateName, value: height)
    }
}
