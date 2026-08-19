//
//  Workspace.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 06.04.26.
//

import CESourceControl
import AppKit
import Combine
import CEWorkspaceFileManager
import CodeEditCore
import CEEditor
import CENotifications
import CESearch
import CETerminal
import SwiftUI
import Foundation

/// A plain model representing an open workspace (folder).
/// Constructed complete by ``WorkspaceFactory/make(url:dependencies:)`` — every
/// manager is non-optional for the workspace's lifetime.
@MainActor
final class Workspace {
    let fileURL: URL
    let displayName: String

    let editorManager: EditorManager
    let workspaceFileManager: CEWorkspaceFileManager
    let sourceControlManager: SourceControlManager
    let sourceControlViewModel: SourceControlViewModel
    let searchState: SearchState
    let taskManager: TaskManager
    let workspaceSettingsManager: CEWorkspaceSettings
    let statePersistence: WorkspaceStatePersistence
    let undoRegistry: UndoManagerRegistry

    // Navigator-coupled — stays until the Navigator feature is packaged
    // (consumed by the ProjectNavigator AppKit cluster and by-workspace command paths).
    let projectNavigatorViewModel: ProjectNavigatorViewModel

    /// Requests to reveal a file in the Project Navigator. The navigator's outline view subscribes
    /// and scrolls to each file. A request is a one-shot event, not retained state — which is why
    /// this is a subject rather than a `@Published` property.
    let revealRequests = PassthroughSubject<CEWorkspaceFile, Never>()

    /// The original (possibly bookmark-derived) security-scoped URL whose access is held for this
    /// workspace's lifetime. Set by `WorkspaceFactory` when the URL is security-scoped (e.g. opened
    /// from recents in the sandbox); released in ``tearDown()``.
    var securityScopedURL: URL?

    init(
        fileURL: URL,
        displayName: String,
        editorManager: EditorManager,
        workspaceFileManager: CEWorkspaceFileManager,
        sourceControlManager: SourceControlManager,
        sourceControlViewModel: SourceControlViewModel,
        searchState: SearchState,
        taskManager: TaskManager,
        workspaceSettingsManager: CEWorkspaceSettings,
        statePersistence: WorkspaceStatePersistence,
        undoRegistry: UndoManagerRegistry,
        projectNavigatorViewModel: ProjectNavigatorViewModel,
        securityScopedURL: URL?
    ) {
        self.fileURL = fileURL
        self.displayName = displayName
        self.editorManager = editorManager
        self.workspaceFileManager = workspaceFileManager
        self.sourceControlManager = sourceControlManager
        self.sourceControlViewModel = sourceControlViewModel
        self.searchState = searchState
        self.taskManager = taskManager
        self.workspaceSettingsManager = workspaceSettingsManager
        self.statePersistence = statePersistence
        self.undoRegistry = undoRegistry
        self.projectNavigatorViewModel = projectNavigatorViewModel
        self.securityScopedURL = securityScopedURL
    }

    // MARK: - Tear Down

    /// Cleanup-only: saves restoration state and releases external resources.
    /// Members are no longer nil-ed — `WorkspaceLifecycleTests` guards against leaks instead.
    func tearDown() {
        editorManager.saveRestorationState(statePersistence)
        workspaceFileManager.cleanUp()
        workspaceSettingsManager.cleanUp()
        securityScopedURL?.stopAccessingSecurityScopedResource()
        securityScopedURL = nil
    }

    // MARK: - Unsaved Changes

    func hasUnsavedChanges() -> Bool {
        let editedFiles = editorManager.editorLayout
            .gatherOpenFiles()
            .compactMap { editorManager.document(for: $0) }
            .filter(\.isDocumentEdited)
        return !editedFiles.isEmpty
    }

    /// Prompts the user to save any unsaved files before closing.
    /// Returns `true` if all files are clean and the workspace can close, `false` if the user cancelled.
    func promptSaveUnsavedFiles() -> Bool {
        let editedCodeFiles = editorManager.editorLayout
            .gatherOpenFiles()
            .compactMap { editorManager.document(for: $0) }
            .filter(\.isDocumentEdited)

        for editedCodeFile in editedCodeFiles {
            let shouldClose = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
            shouldClose.initialize(to: true)
            defer {
                _ = shouldClose.move()
                shouldClose.deallocate()
            }
            editedCodeFile.canClose(
                withDelegate: self,
                shouldClose: #selector(document(_:shouldClose:contextInfo:)),
                contextInfo: shouldClose
            )
            guard shouldClose.pointee else {
                return false
            }
        }

        let areAllClean = editorManager.editorLayout.gatherOpenFiles()
            .compactMap { editorManager.document(for: $0) }
            .allSatisfy { !$0.isDocumentEdited }
        return areAllClean
    }

    @objc
    func document(
        _ document: NSDocument,
        shouldClose: Bool,
        contextInfo: UnsafeMutableRawPointer
    ) {
        let opaquePtr = OpaquePointer(contextInfo)
        let mutablePointer = UnsafeMutablePointer<Bool>(opaquePtr)
        mutablePointer.pointee = shouldClose
    }
}
