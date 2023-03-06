//
//  WorkspaceSplitViewData.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 16/02/2023.
//

import SwiftUI

class SplitViewData: ObservableObject {
    @Published var tabgroups: [TabGroup]

    var axis: Axis

    init(_ axis: Axis, tabgroups: [TabGroup] = []) {
        self.tabgroups = tabgroups
        self.axis = axis

        tabgroups.forEach {
            if case .one(let tabGroupData) = $0 {
                tabGroupData.parent = self
            }
        }
    }

    /// Splits the editor at a certain index into two separate editors.
    func split(_ direction: Edge, at index: Int, new tabgroup: TabGroupData) {
        tabgroup.parent = self
        switch (axis, direction) {
        case (.horizontal, .trailing), (.vertical, .bottom):
            tabgroups.insert(.one(tabgroup), at: index+1)

        case (.horizontal, .leading), (.vertical, .top):
            tabgroups.insert(.one(tabgroup), at: index)

        case (.horizontal, .top):
            tabgroups[index] = .vertical(.init(.vertical, tabgroups: [.one(tabgroup), tabgroups[index]]))

        case (.horizontal, .bottom):
            tabgroups[index] = .vertical(.init(.vertical, tabgroups: [tabgroups[index], .one(tabgroup)]))

        case (.vertical, .leading):
            tabgroups[index] = .horizontal(.init(.horizontal, tabgroups: [.one(tabgroup), tabgroups[index]]))

        case (.vertical, .trailing):
            tabgroups[index] = .horizontal(.init(.horizontal, tabgroups: [tabgroups[index], .one(tabgroup)]))
        }
    }

    func closeTabGroup(with id: TabGroupData.ID) {
        tabgroups.removeAll { tabgroup in
            if case .one(let tabGroupData) = tabgroup {
                if tabGroupData.id == id {
                    return true
                }
            }
            return false
        }
    }

    /// Flattens the splitviews.
    func flatten() {
        for index in tabgroups.indices {
            tabgroups[index].flatten(parent: self)
        }
    }
}
