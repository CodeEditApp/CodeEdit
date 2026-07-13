//
//  CloseWorkspaceUseCase.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 12/04/26.
//

import CELSP
import Foundation

/// Coordinates cleanup when a workspace is closed (LSP shutdown + workspace teardown).
@MainActor
final class CloseWorkspaceUseCase {

    private let lspService: any LSPServiceProtocol

    init(lspService: any LSPServiceProtocol) {
        self.lspService = lspService
    }

    func execute(workspace: Workspace) {
        lspService.closeWorkspace(workspace.fileURL.absoluteURL.path())
        workspace.tearDown()
    }
}
