//
//  TabGroup.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 06/02/2023.
//

import Foundation

enum TabGroup {
    case one(TabGroupData)
    case vertical(WorkspaceSplitViewData)
    case horizontal(WorkspaceSplitViewData)

    func closeAllTabs(of file: WorkspaceClient.FileItem) {
        switch self {
        case .one(let tabGroupData):
            tabGroupData.files.remove(file)
        case .vertical(let data), .horizontal(let data):
            data.tabgroups.forEach {
                $0.closeAllTabs(of: file)
            }
        }
    }

    func findSomeTabGroup() -> TabGroupData? {
        switch self {
        case .one(let tabGroupData):
            return tabGroupData
        case .vertical(let data), .horizontal(let data):
            for tabgroup in data.tabgroups {
                if let result = tabgroup.findSomeTabGroup() {
                    return result
                }
            }
            return nil
        }
    }
}
