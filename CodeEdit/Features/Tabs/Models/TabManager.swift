//
//  TabManager.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 03/03/2023.
//

import Combine
import Foundation
import DequeModule
import OrderedCollections

class TabManager: ObservableObject {
    /// Collection of all the tabgroups.
    @Published var tabGroups: TabGroup

    /// The TabGroup with active focus.
    @Published var activeTabGroup: TabGroupData {
        didSet {
            activeTabGroupHistory.prepend { [weak oldValue] in oldValue }
            switchToActiveTabGroup()
        }
    }

    /// History of last-used tab groups.
    var activeTabGroupHistory: Deque<() -> TabGroupData?> = []

    var fileDocuments: [CEWorkspaceFile: CodeFileDocument] = [:]

    /// notify listeners whenever tab selection changes on the active tab group.
    var tabBarItemIdSubject = PassthroughSubject<TabGroupData.Tab.ID?, Never>()
    var cancellable: AnyCancellable?

    init() {
        let tab = TabGroupData()
        self.activeTabGroup = tab
        self.activeTabGroupHistory.prepend { [weak tab] in tab }
        self.tabGroups = .horizontal(.init(.horizontal, tabgroups: [.one(tab)]))
        switchToActiveTabGroup()
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
    func openTab(item: TabGroupData.Tab, in tabgroup: TabGroupData? = nil) {
        let tabgroup = tabgroup ?? activeTabGroup
        tabgroup.openTab(item: item)
    }

    /// bind active tap group to listen to file selection changes.
    func switchToActiveTabGroup() {
        cancellable?.cancel()
        cancellable = nil
        cancellable = activeTabGroup.$selected
            .sink { [weak self] tab in
                self?.tabBarItemIdSubject.send(tab?.id)
            }
    }
}
