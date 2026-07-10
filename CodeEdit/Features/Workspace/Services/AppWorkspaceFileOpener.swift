//
//  AppWorkspaceFileOpener.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 05/07/2026.
//

import Foundation
import CodeEditCore

/// App-shell binding of the `WorkspaceFileOpener` command interface.
/// Delegates to `WorkspaceWindowManager.openFileInWorkspace(url:)`, which maps the
/// URL to the workspace that owns it, opens the tab, and focuses that workspace.
final class AppWorkspaceFileOpener: WorkspaceFileOpener {
    private let windowManager: WorkspaceWindowManaging

    init(windowManager: WorkspaceWindowManaging) {
        self.windowManager = windowManager
    }

    @MainActor
    func openFile(at url: URL) {
        _ = windowManager.openFileInWorkspace(url: url)
    }
}
