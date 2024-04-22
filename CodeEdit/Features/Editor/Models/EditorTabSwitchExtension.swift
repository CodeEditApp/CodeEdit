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
            selectedTab = tabs[nextIndex]
        } else {
            // Wrap around to the first tab if it's the last one
            selectedTab = tabs.first
        }
    }

    func selectPreviousTab() {
        guard let currentTab = selectedTab, let currentIndex = tabs.firstIndex(of: currentTab) else { return }
        let previousIndex = tabs.index(before: currentIndex)
        if previousIndex >= tabs.startIndex {
            selectedTab = tabs[previousIndex]
        } else {
            // Wrap around to the last tab if it's the first one
            selectedTab = tabs.last
        }
    }
}
