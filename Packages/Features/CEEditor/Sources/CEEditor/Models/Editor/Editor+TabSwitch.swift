//
//  EditorTabSwitchExtension.swift
//  CodeEdit
//
//  Created by Roscoe Rubin-Rottenberg on 4/22/24.
//

import Foundation

extension Editor {
    /// Selects the tab after the current one, wrapping around to the first tab when at the end.
    public func selectNextTab() {
        guard let currentTab = selectedTab, let currentIndex = tabs.firstIndex(of: currentTab) else { return }
        let nextIndex = tabs.index(after: currentIndex)
        if nextIndex < tabs.endIndex {
            setSelectedTab(tabs[nextIndex].file)
        } else {
            // Wrap around to the first tab if it's the last one
            setSelectedTab(tabs.first?.file)
        }
    }

    /// Selects the tab before the current one, wrapping around to the last tab when at the beginning.
    public func selectPreviousTab() {
        guard let currentTab = selectedTab, let currentIndex = tabs.firstIndex(of: currentTab) else { return }
        let previousIndex = tabs.index(before: currentIndex)
        if previousIndex >= tabs.startIndex {
            setSelectedTab(tabs[previousIndex].file)
        } else {
            // Wrap around to the last tab if it's the first one
            setSelectedTab(tabs.last?.file)
        }
    }
}
