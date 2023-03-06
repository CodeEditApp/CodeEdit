//
//  TabManager.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 03/03/2023.
//

import Foundation
import OrderedCollections
import DequeModule

class TabManager: ObservableObject {
    /// Collection of all the tabgroups.
    @Published var tabGroups: TabGroup

    /// The TabGroup with active focus.
    @Published var activeTabGroup: TabGroupData {
        didSet {
            activeTabGroupHistory.prepend { [weak oldValue] in oldValue }
        }
    }

    /// History of last-used tab groups.
    var activeTabGroupHistory: Deque<() -> TabGroupData?> = []

    var fileDocuments: [WorkspaceClient.FileItem: CodeFileDocument] = [:]

    init() {
        let tab = TabGroupData()
        self.activeTabGroup = tab
        self.activeTabGroupHistory.prepend { [weak tab] in tab }
        self.tabGroups = .horizontal(.init(.horizontal, tabgroups: [.one(tab)]))
    }

    /// Flattens the splitviews.
    func flatten() {
        if case .horizontal(let data) = tabGroups {
            data.flatten()
        }
    }


    /// Opens a new tab in a tabgroup.
    /// - Parameters:
    ///   - item: The tab to open.
    ///   - tabgroup: The tabgroup to add the tab to. If nil, it is added to the active tab group.
    func openTab(item: WorkspaceClient.FileItem, in tabgroup: TabGroupData? = nil) {
        let tabgroup = tabgroup ?? activeTabGroup
        tabgroup.openTab(item: item)
    }
}
