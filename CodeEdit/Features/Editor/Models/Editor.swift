//
//  Editor.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 16/02/2023.
//

import Foundation
import OrderedCollections
import DequeModule

final class Editor: ObservableObject, Identifiable {
    typealias Tab = CEWorkspaceFile

    /// Set of open tabs.
    @Published var tabs: OrderedSet<Tab> = [] {
        didSet {
            let change = tabs.symmetricDifference(oldValue)

            if tabs.count > oldValue.count {
                // Amount of tabs grew, so set the first new as selected.
                selectedTab = change.first
            } else {
                // Selected file was removed
                if let selectedTab, change.contains(selectedTab) {
                    if let oldIndex = oldValue.firstIndex(of: selectedTab), oldIndex - 1 < tabs.count, !tabs.isEmpty {
                        self.selectedTab = tabs[max(0, oldIndex-1)]
                    } else {
                        self.selectedTab = nil
                    }
                }
            }
        }
    }

    /// The current offset in the history list.
    @Published var historyOffset: Int = 0 {
        didSet {
            let tab = history[historyOffset]

            if !tabs.contains(tab) {
                if let selectedTab {
                    openTab(item: tab, at: tabs.firstIndex(of: selectedTab), fromHistory: true)
                } else {
                    openTab(item: tab, fromHistory: true)
                }
            }
            selectedTab = tab
        }
    }

    /// History of tab switching.
    @Published var history: Deque<Tab> = []

    /// Currently selected tab.
    @Published var selectedTab: Tab?

    @Published var temporaryTab: Tab?

    var id = UUID()

    weak var parent: SplitViewData?

    init(
        files: OrderedSet<Tab> = [],
        selectedTab: Tab? = nil,
        parent: SplitViewData? = nil
    ) {
        self.tabs = []
        self.parent = parent
        files.forEach { openTab(item: $0) }
        self.selectedTab = selectedTab ?? files.first
    }

    /// Closes the editor.
    func close() {
        parent?.closeEditor(with: id)
    }

    /// Gets the editor layout.
    func getEditorLayout() -> EditorLayout? {
        return parent?.getEditorLayout(with: id)
    }

    /// Closes a tab in the editor.
    /// This will also write any changes to the file on disk and will add the tab to the tab history.
    /// - Parameter item: the tab to close.
    func closeTab(item: Tab) {
        if temporaryTab == item {
            temporaryTab = nil
        }

        historyOffset = 0
        if item != selectedTab {
            history.prepend(item)
        }
        tabs.remove(item)
        if let selectedTab {
            history.prepend(selectedTab)
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
    }

    /// Closes the currently opened tab in the tab group.
    func closeSelectedTab() {
        guard let tab = selectedTab else {
            return
        }

        closeTab(item: tab)
    }

    /// Opens a tab in the editor.
    /// If a tab for the item already exists, it is used instead.
    /// - Parameters:
    ///   - item: the tab to open.
    ///   - asTemporary: indicates whether the tab should be opened as a temporary tab or a permanent tab.
    func openTab(item: Tab, asTemporary: Bool) {
        // Item is already opened in a tab.
        guard !tabs.contains(item) || !asTemporary else {
            selectedTab = item
            history.prepend(item)
            return
        }

        switch (temporaryTab, asTemporary) {
        case (.some(let tab), true):
            if let index = tabs.firstIndex(of: tab) {
                history.prepend(item)
                tabs.remove(tab)
                tabs.insert(item, at: index)
                self.selectedTab = item
                temporaryTab = item
            }

        case (.some(let tab), false) where tab == item:
            temporaryTab = nil

        case (.none, true):
            openTab(item: item)
            temporaryTab = item

        case (.none, false):
            openTab(item: item)

        default:
            break
        }

        do {
            try openFile(item: item)
        } catch {
            print(error)
        }
    }

    /// Opens a tab in the editor.
    /// - Parameters:
    ///   - item: The tab to open.
    ///   - index: Index where the tab needs to be added. If nil, it is added to the back.
    ///   - fromHistory: Indicates whether the tab has been opened from going back in history.
    func openTab(item: Tab, at index: Int? = nil, fromHistory: Bool = false) {
        if let index {
            tabs.insert(item, at: index)
        } else {
            tabs.append(item)
        }
        selectedTab = item
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
    }

    func goBackInHistory() {
        if canGoBackInHistory {
            historyOffset += 1
        }
    }

    func goForwardInHistory() {
        if canGoForwardInHistory {
            historyOffset -= 1
        }
    }

    // TODO: move to @Observable so this works better
    /// Warning: NOT published!
    var canGoBackInHistory: Bool {
        historyOffset != history.count-1 && !history.isEmpty
    }

    // TODO: move to @Observable so this works better
    /// Warning: NOT published!
    var canGoForwardInHistory: Bool {
        historyOffset != 0
    }
}

extension Editor: Equatable, Hashable {
    static func == (lhs: Editor, rhs: Editor) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
