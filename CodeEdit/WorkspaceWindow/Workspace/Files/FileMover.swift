//
//  FileMover.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 15/04/26.
//

import Foundation
import CEWorkspaceFileManager
import CodeEditCore

/// Moves a file within a workspace, closing any open tabs for it and reopening the new location.
///
/// Returns the resolved new file (for non-folder moves) so the caller can update its UI.
@MainActor
final class FileMover {

    func execute(file: CEWorkspaceFile, to destination: URL, in workspace: Workspace) throws -> CEWorkspaceFile? {
        guard let newFile = try workspace.workspaceFileManager.move(file: file, to: destination) else {
            return nil
        }

        guard !newFile.isFolder else {
            return newFile
        }

        if !file.isFolder {
            workspace.editorManager.editorLayout.closeAllTabs(of: file)
        }
        workspace.listenerModel.highlightedFileItem = newFile
        workspace.editorManager.openTab(item: newFile)

        return newFile
    }
}
