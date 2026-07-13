//
//  OpenDocumentUseCase.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 15/04/26.
//

import AppKit
import WelcomeWindow

/// Routes a URL to the appropriate opener: a workspace (folder), an existing workspace's file,
/// or a standalone document via NSDocumentController.
@MainActor
final class OpenDocumentUseCase {
    private let windowManager: WorkspaceWindowManaging

    init(windowManager: WorkspaceWindowManaging) {
        self.windowManager = windowManager
    }

    func execute(url: URL, onCompletion: @escaping () -> Void) {
        do {
            if url.isFolder {
                // Folders are noted as recents in `WorkspaceWindowManager.openWorkspace`.
                try windowManager.openWorkspace(at: url)
                onCompletion()
            } else if windowManager.openFileInWorkspace(url: url) {
                RecentsStore.documentOpened(at: url)
                onCompletion()
            } else {
                NSDocumentController.shared.openDocument(
                    withContentsOf: url, display: true
                ) { _, _, error in
                    if error == nil {
                        RecentsStore.documentOpened(at: url)
                        onCompletion()
                    }
                }
            }
        } catch {
            NSAlert(error: error).runModal()
        }
    }
}
