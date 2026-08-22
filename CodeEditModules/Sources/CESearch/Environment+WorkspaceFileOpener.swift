//
//  Environment+WorkspaceFileOpener.swift
//  Search
//
//  Created by Matthijs Eikelenboom on 10/07/2026.
//

import SwiftUI
import CodeEditCore

private struct WorkspaceFileOpenerKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: WorkspaceFileOpener = NoOpWorkspaceFileOpener()
}

extension EnvironmentValues {
    /// The command used to open a file in the owning workspace.
    /// No-op by default (previews, tests); injected by the app shell.
    public var workspaceFileOpener: WorkspaceFileOpener {
        get { self[WorkspaceFileOpenerKey.self] }
        set { self[WorkspaceFileOpenerKey.self] = newValue }
    }
}
