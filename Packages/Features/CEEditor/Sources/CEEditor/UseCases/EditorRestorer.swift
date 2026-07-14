//
//  EditorRestorer.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 15/04/26.
//

import Foundation
import CodeEditCore
import OSLog
import OrderedCollections

/// Restores an editor layout from persisted state, resolving file references against the current file manager.
public final class EditorRestorer {

    public enum Outcome {
        /// Persisted state was loaded and resolved successfully.
        case restored(layout: EditorLayout, activeEditor: Editor)
        /// Persisted state was found but is empty/invalid; caller should initialize a clean state.
        case shouldInitCleanState
        /// No persisted state exists, or decoding failed; caller should leave the editor as-is.
        case noChange
    }

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "EditorRestorer")

    /// Decodes persisted editor state, validates it, and resolves file references.
    public func execute(
        statePersistence: any WorkspaceStatePersisting,
        fileManager: (any WorkspaceFileProviding)?,
        findReplaceQuery: FindReplaceQuery?,
        editorManager: EditorManager
    ) -> Outcome {
        guard let data = statePersistence.get(.openTabs) as? Data else {
            return .noChange
        }

        do {
            let state = try JSONDecoder().decode(EditorRestorationState.self, from: data)

            guard !state.groups.isEmpty else {
                logger.warning("Empty Editor State found, restoring to clean editor state.")
                return .shouldInitCleanState
            }

            guard let activeEditor = state.groups.find(
                editor: state.activeEditor
            ) ?? state.groups.findSomeEditor() else {
                logger.warning("Editor state could not restore active editor.")
                return .shouldInitCleanState
            }

            try fixRestoredEditorLayout(
                state.groups,
                fileManager: fileManager,
                findReplaceQuery: findReplaceQuery,
                editorManager: editorManager
            )

            return .restored(layout: state.groups, activeEditor: activeEditor)
        } catch {
            logger.warning(
                "Could not restore editor state from saved data: \(error.localizedDescription, privacy: .public)"
            )
            return .noChange
        }
    }

    /// Recursively maps decoded `CEWorkspaceFile` references to their shared file-manager-owned representations.
    private func fixRestoredEditorLayout(
        _ group: EditorLayout,
        fileManager: (any WorkspaceFileProviding)?,
        findReplaceQuery: FindReplaceQuery?,
        editorManager: EditorManager
    ) throws {
        switch group {
        case let .one(data):
            try fixEditor(
                data, fileManager: fileManager, findReplaceQuery: findReplaceQuery, editorManager: editorManager
            )
        case let .vertical(splitData):
            try splitData.editorLayouts.forEach { group in
                try fixRestoredEditorLayout(
                    group, fileManager: fileManager, findReplaceQuery: findReplaceQuery, editorManager: editorManager
                )
            }
        case let .horizontal(splitData):
            try splitData.editorLayouts.forEach { group in
                try fixRestoredEditorLayout(
                    group, fileManager: fileManager, findReplaceQuery: findReplaceQuery, editorManager: editorManager
                )
            }
        }
    }

    /// Resolves all file references on a single editor with the workspace's file manager
    /// and loads each tab's underlying code file.
    private func fixEditor(
        _ editor: Editor,
        fileManager: (any WorkspaceFileProviding)?,
        findReplaceQuery: FindReplaceQuery?,
        editorManager: EditorManager
    ) throws {
        guard let fileManager else { return }
        let resolvedTabs = editor
            .tabs
            .compactMap({ fileManager.getFile($0.file.url.path(percentEncoded: false), createIfNotFound: true) })
            .map({ EditorInstance(findReplaceQuery: findReplaceQuery, file: $0) })

        for tab in resolvedTabs {
            try editorManager.loadDocument(for: tab.file)
        }

        editor.findReplaceQuery = findReplaceQuery
        editor.editorManager = editorManager
        editor.isAttachedToWorkspace = true
        editor.tabs = OrderedSet(resolvedTabs)

        if let selectedTab = editor.selectedTab {
            if let resolvedFile = fileManager.getFile(
                selectedTab.file.url.path(percentEncoded: false),
                createIfNotFound: true
            ) {
                editor.setSelectedTab(resolvedFile)
            } else {
                editor.setSelectedTab(nil)
            }
        }
    }
}
