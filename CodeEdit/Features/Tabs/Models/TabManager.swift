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
    var tabBarItemIdSubject = PassthroughSubject<String?, Never>()
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
    func openTab(item: CEWorkspaceFile, in tabgroup: TabGroupData? = nil) {
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

    /// Restores the tab manager from a captured state obtained using `saveRestorationState`
    /// - Parameter workspace: The workspace to retrieve state from.
    func restoreFromState(_ workspace: WorkspaceDocument) {
        guard let fileManager = workspace.workspaceFileManager,
              let data = workspace.getFromWorkspaceState(.openTabs) as? Data,
              let state = try? JSONDecoder().decode(TabRestorationState.self, from: data) else {
            return
        }
        fixRestoredTabGroup(state.groups, fileManager: fileManager)
        self.tabGroups = state.groups
        self.activeTabGroup = findTabGroup(
            group: state.groups,
            searchFor: state.focus.id
        ) ?? tabGroups.findSomeTabGroup()!
        switchToActiveTabGroup()
    }

    /// Fix any hanging files after restoring from saved state.
    ///
    /// After decoding the state, we're left with `CEWorkspaceFile`s that don't exist in the file manager
    /// so this function maps all those to 'real' files. Works recursively on all the tab groups.
    /// - Parameters:
    ///   - group: The tab group to fix.
    ///   - fileManager: The file manager to use to map files.
    private func fixRestoredTabGroup(_ group: TabGroup, fileManager: CEWorkspaceFileManager) {
        switch group {
        case let .one(data):
            fixTabGroupData(data, fileManager: fileManager)
        case let .vertical(splitData):
            splitData.tabgroups.forEach { group in
                fixRestoredTabGroup(group, fileManager: fileManager)
            }
        case let .horizontal(splitData):
            splitData.tabgroups.forEach { group in
                fixRestoredTabGroup(group, fileManager: fileManager)
            }
        }
    }

    private func findTabGroup(group: TabGroup, searchFor id: UUID) -> TabGroupData? {
        switch group {
        case let .one(data):
            return data.id == id ? data : nil
        case let .vertical(splitData):
            return splitData.tabgroups.compactMap { findTabGroup(group: $0, searchFor: id) }.first
        case let .horizontal(splitData):
            return splitData.tabgroups.compactMap { findTabGroup(group: $0, searchFor: id) }.first
        }
    }

    /// Fixes any hanging files after restoring from saved state.
    /// - Parameters:
    ///   - data: The tab group to fix.
    ///   - fileManager: The file manager to use to map files.a
    private func fixTabGroupData(_ data: TabGroupData, fileManager: CEWorkspaceFileManager) {
        data.tabs = OrderedSet(data.tabs.compactMap { fileManager.getFile($0.url.path) })
        if let selected = data.selected {
            data.selected = fileManager.getFile(selected.url.path)
        }
    }

    func saveRestorationState(_ workspace: WorkspaceDocument) {
        if let data = try? JSONEncoder().encode(
            TabRestorationState(focus: activeTabGroup, groups: tabGroups)
        ) {
            workspace.addToWorkspaceState(key: .openTabs, value: data)
        } else {
            workspace.addToWorkspaceState(key: .openTabs, value: nil)
        }
    }
}
