//
//  TabGroupData.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 16/02/2023.
//

import Foundation
import OrderedCollections

final class TabGroupData: ObservableObject, Identifiable {
    @Published var files: OrderedSet<WorkspaceClient.FileItem> = [] {
        didSet {
            let change = files.symmetricDifference(oldValue)

            if files.count > oldValue.count {
                // Amount of tabs grew, so set the first new as selected.
                selected = change.first
            } else {
                // Selected file was removed
                if let selected, change.contains(selected) {
                    if let oldIndex = oldValue.firstIndex(of: selected), oldIndex - 1 < files.count, !files.isEmpty {
                        self.selected = files[max(0, oldIndex-1)]
                    } else {
                        self.selected = nil
                    }
                }
            }
        }
    }

    @Published var selected: WorkspaceClient.FileItem?

    let id = UUID()

    weak var parent: WorkspaceSplitViewData?

    init(files: OrderedSet<WorkspaceClient.FileItem> = [], selected: WorkspaceClient.FileItem? = nil, parent: WorkspaceSplitViewData? = nil) {
        self.files = files
        self.selected = selected ?? files.first
        self.parent = parent
    }

    func close() {
        parent?.closeTabGroup(with: id)
    }

    deinit {
        print("DEINITING CLASS WITH FILES \(files)")
    }
}

extension TabGroupData: Equatable {
    static func == (lhs: TabGroupData, rhs: TabGroupData) -> Bool {
        lhs.id == rhs.id
    }
}
