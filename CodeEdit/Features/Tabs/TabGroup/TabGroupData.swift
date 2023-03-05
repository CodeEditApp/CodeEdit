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

    /// Set of open tabs.
    @Published var tabs: OrderedSet<Tab> = [] {
        didSet {
            let change = tabs.symmetricDifference(oldValue)

            if tabs.count > oldValue.count {
                // Amount of tabs grew, so set the first new as selected.
                selected = change.first
            } else {
                // Selected file was removed
                if let selected, change.contains(selected) {
                    if let oldIndex = oldValue.firstIndex(of: selected), oldIndex - 1 < tabs.count, !tabs.isEmpty {
                        self.selected = tabs[max(0, oldIndex-1)]
                    } else {
                        self.selected = nil
                    }
                }
            }
        }
    }

    /// History of tab switching.
    @Published var history: Deque<Tab> = []

    /// The current offset in the history list.
    @Published var historyOffset: Int = 0 {
        didSet {
            let tab = history[historyOffset]

            if !tabs.contains(tab) {
                if let selected {
                    openTab(item: tab, at: tabs.firstIndex(of: selected), fromHistory: true)
                } else {
                    openTab(item: tab, fromHistory: true)
                }
            }
            selected = tab
        }
    }

    /// Currently selected tab.
    @Published var selected: Tab?

    var selectedIsTemporary = false

    let id = UUID()

    weak var parent: WorkspaceSplitViewData?

    init(
        files: OrderedSet<Tab> = [],
        selected: Tab? = nil,
        parent: WorkspaceSplitViewData? = nil
    ) {
        self.tabs = []
        self.parent = parent
        files.forEach { openTab(item: $0) }
        self.selected = selected ?? files.first
    }

    /// Closes the tabgroup.
    func close() {
        parent?.closeTabGroup(with: id)
    }

    /// Closes a tab in the tabgroup.
    func closeTab(item: Tab) {
        historyOffset = 0
        if item != selected {
            history.prepend(item)
        }
        tabs.remove(item)
        if let selected {
            history.prepend(selected)
        }

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

//        if openedTabsFromState {
//            var openTabsInState = self.getFromWorkspaceState(key: openTabsStateName) as? [String] ?? []
//            if let index = openTabsInState.firstIndex(of: item.url.absoluteString) {
//                openTabsInState.remove(at: index)
//                self.addToWorkspaceState(key: openTabsStateName, value: openTabsInState)
//            }
//        }
    }

    /// Opens a tab in the tabgroup.
    /// If a tab for the item already exists, it is used instead.
    func openTab(item: Tab, asTemporary: Bool, fromHistory: Bool = false) {
        // Item is already opened in a tab.
        guard !tabs.contains(item) || !asTemporary else {
            selected = item
            history.prepend(item)
            return
        }

        if let selected, let index = tabs.firstIndex(of: selected), asTemporary && selectedIsTemporary {
            // Replace temporary tab
            history.prepend(item)
            tabs.remove(selected)
            tabs.insert(item, at: index)
            self.selected = item
        } else if selectedIsTemporary && !asTemporary {
            // Temporary becomes permanent.
            selectedIsTemporary = false

        } else {
            // New temporary tab
            openTab(item: item)
            selectedIsTemporary = true
        }
        do {
            try openFile(item: item)
        } catch {
            print(error)
        }
    }

    /// Opens a tab in the tabgroup.
    func openTab(item: Tab, at index: Int? = nil, fromHistory: Bool = false) {
        if let index {
            tabs.insert(item, at: index)
        } else {
            tabs.append(item)
        }
        selected = item
        if !fromHistory {
            history.removeFirst(historyOffset)
            history.prepend(item)
            historyOffset = 0
        }
        do {
            try openFile(item: item)
        } catch {
            print(error)
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
        print("Opening file for item: ", item.url)
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
