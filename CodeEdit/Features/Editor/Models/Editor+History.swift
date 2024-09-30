//
//  Editor+History.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/9/24.
//

import Foundation

/// Methods for modifying the history list on the editor.
extension Editor {
    /// Add the tab to the history list.
    /// - Parameter tab: The tab to add to the history.
    func addToHistory(_ tab: Tab) {
        if history.first != tab {
            history.prepend(tab)
        }
    }

    /// Clear any tabs in the "future" on the history list. Resets the history offset and removes any tabs that were
    /// available to navigate forwards to.
    func clearFuture() {
        guard historyOffset > 0 else { return } // nothing to clear, avoid an out of bounds error
        history.removeFirst(historyOffset)
        historyOffset = 0
    }

    /// Move backwards in the history list by one place.
    func goBackInHistory() {
        if canGoBackInHistory {
            historyOffset += 1
        }
    }

    /// Move forwards in the history list by one place.
    func goForwardInHistory() {
        if canGoForwardInHistory {
            historyOffset -= 1
        }
    }

    // TODO: move to @Observable so this works better
    /// Warning: NOT published!
    var canGoBackInHistory: Bool {
        historyOffset != history.count - 1 && !history.isEmpty
    }

    // TODO: move to @Observable so this works better
    /// Warning: NOT published!
    var canGoForwardInHistory: Bool {
        historyOffset != 0
    }

    /// Called by the ``Editor`` class when the history offset is changed.
    ///
    /// This method updates the selected tab to the current tab in the history offset.
    /// If the tab is not opened, it is opened without modifying the history list.
    /// - Warning: Do not use except in the ``historyOffset``'s `didSet`.
    func historyOffsetDidChange() {
        let tab = history[historyOffset]

        if !tabs.contains(tab) {
            if let temporaryTab, tabs.contains(temporaryTab) {
                closeTab(file: temporaryTab.file, fromHistory: true)
            }
            temporaryTab = tab
            openTab(file: tab.file, fromHistory: true)
        }
        selectedTab = tab
    }
}
