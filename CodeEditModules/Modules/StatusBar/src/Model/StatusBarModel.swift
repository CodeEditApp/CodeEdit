//
//  StatusBarModel.swift
//
//
//  Created by Lukas Pistrol on 20.03.22.
//

import GitClient
import SwiftUI

public enum StatusBarTab: String, CaseIterable, Identifiable {
    case terminal
    case debugger
    case output

    public var id: String { return self.rawValue }
}

/// # StatusBarModel
///
/// A model class to host and manage data for the ``StatusBarView``
///
public class StatusBarModel: ObservableObject {
    /// Returns the current active tab
    @Published
    public var activeTab: StatusBarTab = .terminal

    // TODO: Implement logic for updating values
    /// Returns number of errors during comilation
    @Published
    public var errorCount: Int = 0 // Implementation missing

    /// Returns number of warnings during comilation
    @Published
    public var warningCount: Int = 0 // Implementation missing

    /// The selected branch from the GitClient
    @Published
    public var selectedBranch: String?

    /// State of pulling from git
    @Published
    public var isReloading: Bool = false // Implementation missing

    /// Returns the current line of the cursor in an editing view
    @Published
    public var currentLine: Int = 1 // Implementation missing

    /// Returns the current column of the cursor in an editing view
    @Published
    public var currentCol: Int = 1 // Implementation missing

    /// Returns true when the drawer is visible
    @AppStorage("statusbar.isExpanded")
    public var isExpanded: Bool = false

    /// Returns true when the drawer is visible
    @AppStorage("statusbar.isMaximized")
    public var isMaximized: Bool = false

    /// The current height of the drawer. Zero if hidden
    @AppStorage("statusbar.currentHeight")
    public var currentHeight: Double = 0

    /// Indicates whether the drawer is beeing resized or not
    @Published
    public var isDragging: Bool = false

    /// Search value to filter in drawer
    @Published
    public var searchText = ""

    /// Returns the font for status bar items to use
    private(set) var toolbarFont: Font = .system(size: 11)

    /// A GitClient instance
    private(set) var gitClient: GitClient

    /// The base URL of the workspace
    private(set) var workspaceURL: URL

    /// The maximum height of the drawer
    /// when isMaximized is true the height gets set to maxHeight
    private(set) var maxHeight: Double = 5000

    /// The default height of the drawer
    private(set) var standardHeight: Double = 300

    /// The minimum height of the drawe
    private(set) var minHeight: Double = 100

    // TODO: Add @Published vars for indentation, encoding, linebreak

    /// Initialize with a GitClient
    /// - Parameter workspaceURL: the current workspace URL
    ///
    public init(workspaceURL: URL) {
        self.workspaceURL = workspaceURL
        gitClient = GitClient.default(
            directoryURL: workspaceURL,
            shellClient: .live
        )
        do {
            let selectedBranch = try gitClient.getCurrentBranchName()
            self.selectedBranch = selectedBranch
        } catch {
            selectedBranch = nil
        }
    }

    public func setTab(_ tab: StatusBarTab) {
        self.activeTab = tab
    }
}
