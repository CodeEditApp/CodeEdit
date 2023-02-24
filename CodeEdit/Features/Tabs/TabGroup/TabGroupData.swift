//
//  TabGroupData.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 16/02/2023.
//

import Foundation
import OrderedCollections

final class TabGroupData: ObservableObject {
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

    init(files: OrderedSet<WorkspaceClient.FileItem> = [], selected: WorkspaceClient.FileItem? = nil) {
        self.files = files
        self.selected = selected ?? files.first
    }
}
