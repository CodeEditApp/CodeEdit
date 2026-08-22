//
//  Environment+WorkspaceFileProvider.swift
//  CEEditor
//
//  Created by Matthijs Eikelenboom on 12/07/2026.
//

import SwiftUI
import CodeEditCore

private struct WorkspaceFileProviderKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: (any WorkspaceFileProviding)? = nil
}

extension EnvironmentValues {
    /// Read-mostly access to the workspace file tree (see `WorkspaceFileProviding`).
    /// Optional: nil in previews and tests; injected by the app shell.
    public var workspaceFileProvider: (any WorkspaceFileProviding)? {
        get { self[WorkspaceFileProviderKey.self] }
        set { self[WorkspaceFileProviderKey.self] = newValue }
    }
}
