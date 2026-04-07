//
//  URL+FindWorkspace.swift
//  CodeEdit
//
//  Created by Khan Winter on 12/19/24.
//

import Foundation

extension URL {
    /// Finds a workspace that contains the url.
    @MainActor
    func findWorkspace() -> Workspace? {
        @Service var windowManager: WorkspaceWindowManager
        return windowManager.workspace(containing: self)
    }
}
