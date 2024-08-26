//
//  OutlintViewController+OutlineTableViewCellDelegate.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2023/2/5.
//

import Foundation

// MARK: - OutlineTableViewCellDelegate

extension ProjectNavigatorViewController: OutlineTableViewCellDelegate {
    func moveFile(file: CEWorkspaceFile, to destination: URL) {
        if !file.isFolder {
            workspace?.editorManager?.editorLayout.closeAllTabs(of: file)
        }
        workspace?.workspaceFileManager?.move(file: file, to: destination)
        if let parent = file.parent {
            do {
                try workspace?.workspaceFileManager?.rebuildFiles(fromItem: parent)

                // Grab the file connected to the rest of the cached file tree.
                guard let newFile = workspace?.workspaceFileManager?.getFile(
                    destination.absoluteURL.path(percentEncoded: false)
                ),
                      !newFile.isFolder else {
                    return
                }

                workspace?.editorManager?.openTab(item: newFile)
            } catch {
                Self.logger.error("Failed to rebuild file item after moving: \(error)")
            }
        }
    }

    func copyFile(file: CEWorkspaceFile, to destination: URL) {
        workspace?.workspaceFileManager?.copy(file: file, to: destination)
    }
}
