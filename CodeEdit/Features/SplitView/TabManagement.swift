//
//  TabManager.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 03/03/2023.
//

import Foundation
import OrderedCollections

class TabManager: ObservableObject {
    @Published var tabs: TabGroup

    @Published var activeTab: TabGroupData {
        didSet {
            activeTabHistory.updateOrInsert(oldValue, at: 0)
        }
    }

    var activeTabHistory: OrderedSet<TabGroupData> = []

    init() {
        let tab = TabGroupData()
        self.activeTab = tab
        self.activeTabHistory.append(tab)
        self.tabs = .horizontal(.init(.horizontal, tabgroups: [.one(tab)]))
    }
}
