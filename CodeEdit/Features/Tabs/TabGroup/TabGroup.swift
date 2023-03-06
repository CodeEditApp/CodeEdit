//
//  TabGroup.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 06/02/2023.
//

import Foundation

enum TabGroup {
    case one(TabGroupData)
    case vertical(SplitViewData)
    case horizontal(SplitViewData)

    func closeAllTabs(of file: WorkspaceClient.FileItem) {
        switch self {
        case .one(let tabGroupData):
            tabGroupData.tabs.remove(file)
        case .vertical(let data), .horizontal(let data):
            data.tabgroups.forEach {
                $0.closeAllTabs(of: file)
            }
        }
    }

    /// Returns some tabgroup, except the given tabgroup.
    func findSomeTabGroup(except: TabGroupData? = nil) -> TabGroupData? {
        switch self {
        case .one(let tabGroupData) where tabGroupData != except:
            return tabGroupData
        case .vertical(let data), .horizontal(let data):
            for tabgroup in data.tabgroups {
                if let result = tabgroup.findSomeTabGroup(except: except), result != except {
                    return result
                }
            }
            return nil
        default:
            return nil
        }
    }

    /// Forms a set of all files currently represented by tabs.
    func gatherOpenFiles() -> Set<WorkspaceClient.FileItem> {
        switch self {
        case .one(let tabGroupData):
            return Set(tabGroupData.tabs)
        case .vertical(let data), .horizontal(let data):
            return data.tabgroups.map { $0.gatherOpenFiles() }.reduce(into: []) { $0.formUnion($1) }
        }
    }
}
