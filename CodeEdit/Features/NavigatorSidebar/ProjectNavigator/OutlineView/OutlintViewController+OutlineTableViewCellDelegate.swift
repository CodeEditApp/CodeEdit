//
//  OutlintViewController+OutlineTableViewCellDelegate.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2023/2/5.
//

import Foundation

// MARK: - OutlineTableViewCellDelegate

extension OutlineViewController: OutlineTableViewCellDelegate {
    func moveFile(file: Item, to destination: URL) {
        if !file.isFolder {
            workspace?.closeTab(item: .codeEditor(file.id))
        }
        file.move(to: destination)
        if !file.isFolder {
            workspace?.openTab(item: file)
        }
    }

    func copyFile(file: WorkspaceClient.FileItem, to destination: URL) {
        file.duplicate(to: destination)
    }
}
