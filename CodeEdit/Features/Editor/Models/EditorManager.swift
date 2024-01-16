//
//  TabManager.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 03/03/2023.
//

import Combine
import Foundation
import DequeModule
import OrderedCollections
import os

class EditorManager: ObservableObject {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "EditorManager")

    /// The complete editor layout.
    @Published var editorLayout: EditorLayout

    @Published var isFocusingActiveEditor: Bool

    /// The Editor with active focus.
    @Published var activeEditor: Editor {
        didSet {
            activeEditorHistory.prepend { [weak oldValue] in oldValue }
            switchToActiveEditor()
        }
    }

    /// History of last-used editors.
    var activeEditorHistory: Deque<() -> Editor?> = []

    var fileDocuments: [CEWorkspaceFile: CodeFileDocument] = [:]

    /// notify listeners whenever tab selection changes on the active editor.
    var tabBarTabIdSubject = PassthroughSubject<String?, Never>()
    var cancellable: AnyCancellable?

    // MARK: - Init

    init() {
        let tab = Editor()
        self.activeEditor = tab
        self.activeEditorHistory.prepend { [weak tab] in tab }
        self.editorLayout = .horizontal(.init(.horizontal, editorLayouts: [.one(tab)]))
        self.isFocusingActiveEditor = false
        switchToActiveEditor()
    }

    /// Initializes the editor manager's state to the "initial" state.
    ///
    /// Functionally identical to the initializer for this class.
    func initCleanState() {
        let tab = Editor()
        self.activeEditor = tab
        self.activeEditorHistory.prepend { [weak tab] in tab }
        self.editorLayout = .horizontal(.init(.horizontal, editorLayouts: [.one(tab)]))
        self.isFocusingActiveEditor = false
        switchToActiveEditor()
    }

    /// Flattens the splitviews.
    func flatten() {
        if case .horizontal(let data) = editorLayout {
            data.flatten()
        } else if case .vertical(let data) = editorLayout {
            data.flatten()
        }
    }

    /// Opens a new tab in a editor.
    /// - Parameters:
    ///   - item: The tab to open.
    ///   - editor: The editor to add the tab to. If nil, it is added to the active tab group.
    func openTab(item: CEWorkspaceFile, in editor: Editor? = nil) {
        let editor = editor ?? activeEditor
        editor.openTab(file: item)
    }

    /// bind active tap group to listen to file selection changes.
    func switchToActiveEditor() {
        cancellable?.cancel()
        cancellable = nil
        cancellable = activeEditor.$selectedTab
            .sink { [weak self] tab in
                self?.tabBarTabIdSubject.send(tab?.file.id)
            }
    }

    // MARK: - Close Editor

    /// Close an editor and fix editor manager state, updating active editor, etc.
    /// - Parameter editor: The editor to close
    func closeEditor(_ editor: Editor) {
        editor.close()
        if activeEditor == editor {
            setNewActiveEditor(excluding: editor)
        }

        flatten()
        objectWillChange.send()
    }

    /// Fix any hanging files after restoring from saved state.
    ///
    /// After decoding the state, we're left with `CEWorkspaceFile`s that don't exist in the file manager
    /// so this function maps all those to 'real' files. Works recursively on all the tab groups.
    /// - Parameters:
    ///   - group: The tab group to fix.
    ///   - fileManager: The file manager to use to map files.
    private func fixRestoredEditorLayout(_ group: EditorLayout, fileManager: CEWorkspaceFileManager) {
        switch group {
        case let .one(data):
            fixEditor(data, fileManager: fileManager)
        case let .vertical(splitData):
            splitData.editorLayouts.forEach { group in
                fixRestoredEditorLayout(group, fileManager: fileManager)
            }
        case let .horizontal(splitData):
            splitData.editorLayouts.forEach { group in
                fixRestoredEditorLayout(group, fileManager: fileManager)
            }
        }
    }

    private func findEditorLayout(group: EditorLayout, searchFor id: UUID) -> Editor? {
        switch group {
        case let .one(data):
            return data.id == id ? data : nil
        case let .vertical(splitData):
            return splitData.editorLayouts.compactMap { findEditorLayout(group: $0, searchFor: id) }.first
        case let .horizontal(splitData):
            return splitData.editorLayouts.compactMap { findEditorLayout(group: $0, searchFor: id) }.first
        }
    }

    /// Fixes any hanging files after restoring from saved state.
    /// - Parameters:
    ///   - data: The tab group to fix.
    ///   - fileManager: The file manager to use to map files.a
    private func fixEditor(_ editor: Editor, fileManager: CEWorkspaceFileManager) {
        editor.tabs = OrderedSet(
            editor
                .tabs
                .compactMap({ fileManager.getFile($0.file.url.path, createIfNotFound: true) })
                .map({ EditorInstance(file: $0) })
        )
        if let selectedTab = editor.selectedTab,
            let file = fileManager.getFile(selectedTab.file.url.path, createIfNotFound: true) {
            editor.selectedTab = EditorInstance(file: file)
        } else {
            editor.selectedTab = nil
        }
    }

    func saveRestorationState(_ workspace: WorkspaceDocument) {
        if let data = try? JSONEncoder().encode(
            EditorRestorationState(focus: activeEditor, groups: editorLayout)
        ) {
            workspace.addToWorkspaceState(key: .openTabs, value: data)
    /// Set a new active editor.
    /// - Parameter editor: The editor to exclude.
    func setNewActiveEditor(excluding editor: Editor) {
        activeEditorHistory.removeAll { $0() == nil || $0() == editor }
        if activeEditorHistory.isEmpty {
            activeEditor = findSomeEditor(excluding: editor)
        } else {
            activeEditor = activeEditorHistory.removeFirst()()!
        }
    }

    /// Find some editor, or if one cannot be found set up the editor manager with a clean state.
    /// - Parameter editor: The editor to exclude.
    /// - Returns: Some editor, order is not guaranteed.
    func findSomeEditor(excluding editor: Editor) -> Editor {
        guard let someEditor = editorLayout.findSomeEditor(except: editor) else {
            initCleanState()
            return activeEditor
        }
        return someEditor
    }

    // MARK: - Focus

    func toggleFocusingEditor(from editor: Editor) {
        if !isFocusingActiveEditor {
            activeEditor = editor
        }
        isFocusingActiveEditor.toggle()
    }
}
