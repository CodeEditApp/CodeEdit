//
//  EditorManager.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 03/03/2023.
//

import Combine
import CodeEditDocument
import CodeEditCore
import Foundation
import DequeModule
import os

public class EditorManager: ObservableObject {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "EditorManager")

    /// Owns the file→document association for this workspace.
    public let documents = DocumentRegistry()

    /// The complete editor layout.
    @Published public var editorLayout: EditorLayout

    @Published public var isFocusingActiveEditor: Bool

    /// The Editor with active focus.
    @Published public var activeEditor: Editor {
        didSet {
            activeEditorHistory.prepend { [weak oldValue] in oldValue }
            switchToActiveEditor()
        }
    }

    /// History of last-used editors.
    public var activeEditorHistory: Deque<() -> Editor?> = []

    /// notify listeners whenever tab selection changes on the active editor.
    public var tabBarTabIdSubject = PassthroughSubject<Editor.Tab?, Never>()
    var cancellable: AnyCancellable?

    // This caching mechanism is a temporary solution and is not optimized
    @Published public var updateCachedFlattenedEditors: Bool = true
    public var cachedFlettenedEditors: [Editor] = []
    public var flattenedEditors: [Editor] {
        if updateCachedFlattenedEditors {
            cachedFlettenedEditors = self.getFlattened()
            updateCachedFlattenedEditors = false
        }
        return cachedFlettenedEditors
    }

    // MARK: - Init

    public init() {
        let tab = Editor()
        self.activeEditor = tab
        self.activeEditorHistory.prepend { [weak tab] in tab }
        self.editorLayout = .horizontal(.init(.horizontal, editorLayouts: [.one(tab)]))
        self.isFocusingActiveEditor = false
        tab.editorManager = self
        switchToActiveEditor()
    }

    /// Initializes the editor manager's state to the "initial" state.
    ///
    /// Functionally identical to the initializer for this class.
    public func initCleanState() {
        let tab = Editor()
        self.activeEditor = tab
        self.activeEditorHistory.prepend { [weak tab] in tab }
        self.editorLayout = .horizontal(.init(.horizontal, editorLayouts: [.one(tab)]))
        self.isFocusingActiveEditor = false
        tab.editorManager = self
        switchToActiveEditor()
    }

    /// Flattens the splitviews.
    public func flatten() {
        switch editorLayout {
        case .horizontal(let data), .vertical(let data):
            data.flatten()
        default:
            break
        }
    }

    /// Returns and array of flattened splitviews.
    public func getFlattened() -> [Editor] {
        switch editorLayout {
        case .horizontal(let data), .vertical(let data):
            return data.getFlattened()
        default:
            return []
        }
    }

    /// Opens a new tab in a editor.
    /// - Parameters:
    ///   - item: The tab to open.
    ///   - editor: The editor to add the tab to. If nil, it is added to the active tab group.
    ///   - asTemporary: Indicates whether the tab should be opened as a temporary tab or a permanent tab.
    public func openTab(item: CEWorkspaceFile, in editor: Editor? = nil, asTemporary: Bool = false) {
        let editor = editor ?? activeEditor
        editor.openTab(file: item, asTemporary: asTemporary)
    }

    /// bind active tap group to listen to file selection changes.
    public func switchToActiveEditor() {
        cancellable?.cancel()
        cancellable = nil
        cancellable = activeEditor.$selectedTab
            .sink { [weak self] tab in
                self?.tabBarTabIdSubject.send(tab)
            }
    }

    // MARK: - Close Editor

    /// Close an editor and fix editor manager state, updating active editor, etc.
    /// - Parameter editor: The editor to close
    public func closeEditor(_ editor: Editor) {
        editor.close()
        if activeEditor == editor {
            setNewActiveEditor(excluding: editor)
        }

        flatten()
        objectWillChange.send()
        updateCachedFlattenedEditors = true
    }

    /// Set a new active editor.
    /// - Parameter editor: The editor to exclude.
    public func setNewActiveEditor(excluding editor: Editor) {
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
    public func findSomeEditor(excluding editor: Editor) -> Editor {
        guard let someEditor = editorLayout.findSomeEditor(except: editor) else {
            initCleanState()
            return activeEditor
        }
        return someEditor
    }

    // MARK: - Focus

    public func toggleFocusingEditor(from editor: Editor) {
        if !isFocusingActiveEditor {
            activeEditor = editor
        }
        isFocusingActiveEditor.toggle()
    }

    // MARK: - Documents

    public func document(for file: CEWorkspaceFile) -> CodeFileDocument? {
        documents.document(for: file)
    }

    public func setDocument(_ document: CodeFileDocument?, for file: CEWorkspaceFile) {
        documents.setDocument(document, for: file)
    }

    @discardableResult
    public func loadDocument(for file: CEWorkspaceFile) throws -> CodeFileDocument {
        try documents.loadDocument(for: file)
    }

    public func documentPublisher(for file: CEWorkspaceFile) -> AnyPublisher<CodeFileDocument?, Never> {
        documents.documentPublisher(for: file)
    }
}
