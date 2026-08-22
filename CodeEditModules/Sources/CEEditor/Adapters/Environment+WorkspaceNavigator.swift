//
//  Environment+WorkspaceNavigator.swift
//  Editor
//
//  Created by Matthijs Eikelenboom on 10/07/2026.
//

import SwiftUI
import CodeEditCore

private struct WorkspaceNavigatorKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: WorkspaceNavigator = NoOpWorkspaceNavigator()
}

extension EnvironmentValues {
    /// The command interface for opening, revealing, and closing files in the owning
    /// workspace. No-op by default (previews, tests); injected by the app shell.
    public var workspaceNavigator: WorkspaceNavigator {
        get { self[WorkspaceNavigatorKey.self] }
        set { self[WorkspaceNavigatorKey.self] = newValue }
    }
}
