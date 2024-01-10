//
//  Tab.swift
//  CodeEdit
//
//  Created by Wouter on 27/12/23.
//

import SwiftUI

extension TabViewTabBar {
    struct Tab: Identifiable, Hashable {
        let title: String?
        let image: Image
        let id: AnyHashable
        let tag: TabID?
        let onMove: ((IndexSet, Int) -> Void)?
        let onDelete: ((IndexSet) -> Void)?
        let onInsert: OnInsertConfiguration?
        let dynamicViewID: Int?
        let dynamicViewContentOffset: Int?

        // We only want to compare ID so view updates are correctly animated
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        static func == (lhs: TabViewTabBar<TabID>.Tab, rhs: TabViewTabBar<TabID>.Tab) -> Bool {
            lhs.id == rhs.id
        }
    }
}
