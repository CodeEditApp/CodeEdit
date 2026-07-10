//
//  Environment+WorkspaceFileManager.swift
//  CEWorkspaceFileManager
//
//  Created by Matthijs Eikelenboom on 03/07/2026.
//

import SwiftUI

private struct WorkspaceFileManagerKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: CEWorkspaceFileManager? = nil
}

public extension EnvironmentValues {
    var workspaceFileManager: CEWorkspaceFileManager? {
        get { self[WorkspaceFileManagerKey.self] }
        set { self[WorkspaceFileManagerKey.self] = newValue }
    }
}
