//
//  OutlintViewController+OutlineTableViewCellDelegate.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2023/2/5.
//

import Foundation

// MARK: - OutlineTableViewCellDelegate

extension ProjectNavigatorViewController: OutlineTableViewCellDelegate {
    
    func moveFile(file: any Resource, to destination: URL) {
        // FIXME:
        // Tabs shouldn't get closed anymore, only move
//        if !file.isFolder {
//            workspace?.tabManager.tabGroups.closeAllTabs(of: file)
//        }
//        file.move(to: destination)
//        if !file.isFolder {
//            workspace?.tabManager.openTab(item: file)
//        }
    }

    func copyFile(file: any Resource, to destination: URL) {
        // FIXME: 
//        file.duplicate()
    }
}
