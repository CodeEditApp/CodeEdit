//
//  SplitViewData.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 16/02/2023.
//

import SwiftUI

final class SplitViewData: ObservableObject {
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
    /// - Parameters:
    ///   - direction: direction in which the editor will be split.
    ///   If the direction is the same as the ancestor direction,
    ///   the editor is added to the ancestor instead of creating a new split container.
    ///   - index: index where the divider will be added.
    ///   - tabgroup: new tabgroup class that will be used for the editor.
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

    /// Closes a TabGroup.
    /// - Parameter id: ID of the TabGroup.
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
