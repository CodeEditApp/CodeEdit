//
//  ProjectNavigatorViewController+OutlineTableViewCellDelegate.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2023/2/5.
//

import Foundation
import CEWorkspaceFileManager
import CodeEditCore
import AppKit

// MARK: - OutlineTableViewCellDelegate

extension ProjectNavigatorViewController: OutlineTableViewCellDelegate {
    func moveFile(file: CEWorkspaceFile, to destination: URL) {
        guard let workspace else { return }
        do {
            let fileMover = FileMover()
            _ = try fileMover.execute(file: file, to: destination, in: workspace)
            outlineView.reloadItem(file.parent, reloadChildren: true)
        } catch {
            let alert = NSAlert(error: error)
            alert.addButton(withTitle: "Dismiss")
            alert.runModal()
        }
    }

    func copyFile(file: CEWorkspaceFile, to destination: URL) {
        do {
            try workspace?.workspaceFileManager.copy(file: file, to: destination)
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
