//
//  URL+FindWorkspace.swift
//  CodeEdit
//
//  Created by Khan Winter on 12/19/24.
//

import Foundation
import Factory

extension URL {
    /// Finds a workspace that contains the url.
    @MainActor
    func findWorkspace() -> Workspace? {
        let windowManager = Container.shared.workspaceWindowManager()
        return windowManager.workspace(containing: self)
    }
}
