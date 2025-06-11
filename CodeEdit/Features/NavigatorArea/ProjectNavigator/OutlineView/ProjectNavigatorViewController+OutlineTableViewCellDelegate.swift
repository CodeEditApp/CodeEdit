//
//  OutlintViewController+OutlineTableViewCellDelegate.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2023/2/5.
//

import Foundation
import AppKit

// MARK: - OutlineTableViewCellDelegate

extension ProjectNavigatorViewController: OutlineTableViewCellDelegate {
    func moveFile(file: CEWorkspaceFile, to destination: URL) {
        do {
            guard let newFile = try workspace?.workspaceFileManager?.move(file: file, to: destination),
                  !newFile.isFolder else {
                return
            }
            outlineView.reloadItem(file.parent, reloadChildren: true)
            if !file.isFolder {
                workspace?.editorManager?.editorLayout.closeAllTabs(of: file)
            }
            workspace?.listenerModel.highlightedFileItem = newFile
            workspace?.editorManager?.openTab(item: newFile)
        } catch {
            let alert = NSAlert(error: error)
            alert.addButton(withTitle: "Dismiss")
            alert.runModal()
        }
    }

    func copyFile(file: CEWorkspaceFile, to destination: URL) {
        do {
            try workspace?.workspaceFileManager?.copy(file: file, to: destination)
        } catch {
            let alert = NSAlert(error: error)
            alert.addButton(withTitle: "Dismiss")
            alert.runModal()
        }
    }

    func cellDidFinishEditing() {
        guard shouldReloadAfterDoneEditing else { return }
        outlineView.reloadData()
    }
}
