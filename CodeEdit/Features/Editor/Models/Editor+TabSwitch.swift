//
//  EditorTabSwitchExtension.swift
//  CodeEdit
//
//  Created by Roscoe Rubin-Rottenberg on 4/22/24.
//

import Foundation

extension Editor {
    func selectNextTab() {
        guard let currentTab = selectedTab, let currentIndex = tabs.firstIndex(of: currentTab) else { return }
        let nextIndex = tabs.index(after: currentIndex)
        if nextIndex < tabs.endIndex {
            setSelectedTab(tabs[nextIndex].file)
        } else {
            // Wrap around to the first tab if it's the last one
            setSelectedTab(tabs.first?.file)
        }
    }

    func selectPreviousTab() {
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
