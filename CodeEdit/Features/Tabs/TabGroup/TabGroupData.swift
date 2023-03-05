//
//  TabGroupData.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 16/02/2023.
//

import Foundation
import OrderedCollections
import DequeModule

final class TabGroupData: ObservableObject, Identifiable {
    typealias Tab = WorkspaceClient.FileItem

    @Published var files: OrderedSet<Tab> = [] {
        didSet {
            let change = files.symmetricDifference(oldValue)

            if files.count > oldValue.count {
                // Amount of tabs grew, so set the first new as selected.
                selected = change.first
                history.prepend(contentsOf: change)
                historyOffset = 0
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

    @Published var history: Deque<Tab> = []
    @Published var historyOffset: Int = 0 {
        didSet {
            selected = history[historyOffset]
        }
    }

    @Published var selected: Tab?

    let id = UUID()

    weak var parent: WorkspaceSplitViewData?

    init(
        files: OrderedSet<Tab> = [],
        selected: Tab? = nil,
        parent: WorkspaceSplitViewData? = nil
    ) {
        self.files = files
        self.selected = selected ?? files.first
        self.parent = parent
    }

    func close() {
        parent?.closeTabGroup(with: id)
    }

    func closeTab(item: Tab) {
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

    func openTab(item: Tab, at index: Int? = nil) {
        Task {
            await MainActor.run {
                if let index {
                    files.insert(item, at: index)
                } else {
                    files.append(item)
                }
                selected = item
                do {
                    try openFile(item: item)
                } catch {
                    Swift.print(error)
                }
            }
        }
    }

    private func openFile(item: Tab) throws {
        guard item.fileDocument == nil else {
            return
        }

        let contentType = try item.url.resourceValues(forKeys: [.contentTypeKey]).contentType
        let codeFile = try CodeFileDocument(
            for: item.url,
            withContentsOf: item.url,
            ofType: contentType?.identifier ?? ""
        )
        item.fileDocument = codeFile
        CodeEditDocumentController.shared.addDocument(codeFile)
        Swift.print("Opening file for item: ", item.url)
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
