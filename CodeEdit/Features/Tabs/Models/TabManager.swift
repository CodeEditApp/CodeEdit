//
//  TabManager.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 03/03/2023.
//

import Foundation
import OrderedCollections

class TabManager: ObservableObject {
    /// Collection of all the tabgroups.
    @Published var tabGroups: TabGroup

    /// The TabGroup with active focus.
    @Published var activeTabGroup: TabGroupData {
        didSet {
            activeTabGroupHistory.updateOrInsert(oldValue, at: 0)
        }
    }

    /// History of last-used tab groups.
    var activeTabGroupHistory: OrderedSet<TabGroupData> = []

    var fileDocuments: [WorkspaceClient.FileItem: CodeFileDocument] = [:]

    init() {
        let tab = TabGroupData()
        self.activeTabGroup = tab
        self.activeTabGroupHistory.append(tab)
        self.tabGroups = .horizontal(.init(.horizontal, tabgroups: [.one(tab)]))
    }

    /// Opens a new tab in a tabgroup. If no tabgroup is given, it is added to the active tab group.
    func openTab(item: WorkspaceClient.FileItem, in tabgroup: TabGroupData? = nil) {
        let tabgroup = tabgroup ?? activeTabGroup
        tabgroup.openTab(item: item)
    }
}
