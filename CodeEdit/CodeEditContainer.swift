//
//  CodeEditContainer.swift
//  CodeEdit
//
//  Created by CodeEdit Contributors on 08.04.26.
//

import Factory

extension Container {
    var lspService: Factory<LSPService> {
        self { @MainActor in LSPService() }.singleton
    }

    var workspaceWindowManager: Factory<WorkspaceWindowManager> {
        self { @MainActor in WorkspaceWindowManager() }.singleton
    }
}
