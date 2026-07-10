//
//  URL+FindWorkspace.swift
//  CodeEdit
//
//  Created by Khan Winter on 12/19/24.
//

import Foundation

extension URL {
    /// Finds a workspace that contains the url.
    ///
    /// Bridge-phase shim: remaining callers (LSP cluster) receive an injected
    /// window manager in a later migration task, after which this file is deleted.
    @MainActor
    func findWorkspace() -> Workspace? {
        AppDependencies.bridgeShared.workspaceWindowManager.workspace(containing: self)
    }
}
