//
//  CloseWorkspaceUseCase.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 12/04/26.
//

import Foundation
import Factory

/// Coordinates cleanup when a workspace is closed (LSP shutdown + workspace teardown).
@MainActor
final class CloseWorkspaceUseCase {

    @LazyInjected(\.lspService)
    private var lspService

    func execute(workspace: Workspace) {
        if let path = workspace.fileURL?.absoluteURL.path() {
            lspService.closeWorkspace(path)
        }
        workspace.tearDown()
    }
}
