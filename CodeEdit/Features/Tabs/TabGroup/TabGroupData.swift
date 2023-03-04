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

    func closeTab(item: WorkspaceClient.FileItem) {
        guard let file = item.fileDocument else { return }

        if file.isDocumentEdited {
            let shouldClose = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
            shouldClose.initialize(to: true)
            defer {
                _ = shouldClose.move()
                shouldClose.deallocate()
            }
            file.canClose(
                withDelegate: self,
                shouldClose: #selector(WorkspaceDocument.document(_:shouldClose:contextInfo:)),
                contextInfo: shouldClose
            )
            guard shouldClose.pointee else {
                return
            }
        }
        files.remove(item)

//        if openedTabsFromState {
//            var openTabsInState = self.getFromWorkspaceState(key: openTabsStateName) as? [String] ?? []
//            if let index = openTabsInState.firstIndex(of: item.url.absoluteString) {
//                openTabsInState.remove(at: index)
//                self.addToWorkspaceState(key: openTabsStateName, value: openTabsInState)
//            }
//        }
    }

}

extension TabGroupData: Equatable, Hashable {
    static func == (lhs: TabGroupData, rhs: TabGroupData) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
