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
            workspace?.editorManager.editorLayout.closeAllTabs(of: file)
        }
        file.move(to: destination)
        if !file.isFolder {
            workspace?.editorManager.openTab(item: .init(url: destination))
        }
    }

    func copyFile(file: CEWorkspaceFile, to destination: URL) {
        file.duplicate()
    }
}
