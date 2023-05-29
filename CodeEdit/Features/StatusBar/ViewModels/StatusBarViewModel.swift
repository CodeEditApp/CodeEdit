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

    enum Tab: Hashable {
        case terminal
        case debugger
        case output(ExtensionInfo)

        static func allCases(extensions: [ExtensionInfo]) -> [Tab] {
            [.terminal, .debugger] + extensions.map { .output($0) }
        }
    }

    private let isStatusBarDrawerCollapsedStateName: String
        = "\(String(describing: StatusBarViewModel.self))-IsStatusBarDrawerCollapsed"
    private let statusBarDrawerHeightStateName: String
        = "\(String(describing: StatusBarViewModel.self))-StatusBarDrawerHeight"

    @Published
    var selectedTab: Tab = .terminal

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

    /// Indicates whether the drawer is being resized or not
    @Published
    var isDragging: Bool = false

    /// Indicates whether the breakpoint is enabled or not
    @Published
    var isBreakpointEnabled: Bool = true

    /// Search value to filter in drawer
    @Published
    var searchText: String = ""

    /// Returns the font for status bar items to use
    private(set) var toolbarFont: Font = .system(size: 11, weight: .medium)

    /// The maximum height of the drawer
    /// when isMaximized is true the height gets set to maxHeight
    private(set) var maxHeight: Double = 5000

    /// The default height of the drawer
    private(set) var standardHeight: Double = 300

    /// The minimum height of the drawer
    private(set) var minHeight: Double = 100

    init() {
        // !!!: Lots of things in this class can be removed, such as maxHeight, as they are defined in the UI.
    }
}
