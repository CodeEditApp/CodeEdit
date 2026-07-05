//
//  Workspace.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 06.04.26.
//

import AppKit
import Notifications
import Search
import SwiftUI
import Foundation

/// A plain model representing an open workspace (folder).
/// Replaces `WorkspaceDocument` (NSDocument) with no framework coupling.
@MainActor
final class Workspace: ObservableObject, WorkspaceManaging {
    var projectNavigatorViewModel: ProjectNavigatorViewModel? = ProjectNavigatorViewModel()

    var fileURL: URL?
    var displayName: String = ""

    var workspaceFileManager: CEWorkspaceFileManager?
    var editorManager: EditorManager? = EditorManager()
    var statusBarViewModel: StatusBarViewModel? = StatusBarViewModel()
    var utilityAreaModel: UtilityAreaViewModel? = UtilityAreaViewModel()
    var searchState: SearchState?
    var openQuicklyViewModel: OpenQuicklyViewModel?
    var commandsPaletteState: QuickActionsViewModel?
    var listenerModel: WorkspaceNotificationModel = .init()
    var sourceControlManager: SourceControlManager?
    var sourceControlViewModel: SourceControlViewModel?

    var taskManager: TaskManager?
    var workspaceSettingsManager: CEWorkspaceSettings?
    var taskNotificationHandler: TaskNotificationHandler = TaskNotificationHandler()

    var statePersistence: WorkspaceStatePersistence?

    var undoRegistration: UndoManagerRegistration = UndoManagerRegistration()

    var notificationPanel = NotificationPanelViewModel()

    /// The original (possibly bookmark-derived) security-scoped URL whose access is held for this
    /// workspace's lifetime. Set by `WorkspaceFactory` when the URL is security-scoped (e.g. opened
    /// from recents in the sandbox); released in ``tearDown()``.
    var securityScopedURL: URL?

    // MARK: - Initialization

    init(url: URL) {
        WorkspaceFactory.populate(self, url: url)
    }

    /// Minimal initializer for testing. Does not set up workspace state.
    internal init() {}

    // MARK: - Tear Down

    func tearDown() {
        if let statePersistence {
            editorManager?.saveRestorationState(statePersistence)
            utilityAreaModel?.saveRestorationState(statePersistence)
        }

        statusBarViewModel = nil
        utilityAreaModel = nil
        searchState = nil
        editorManager = nil
        openQuicklyViewModel = nil
        commandsPaletteState = nil
        sourceControlManager = nil
        sourceControlViewModel = nil
        projectNavigatorViewModel = nil
        workspaceFileManager?.cleanUp()
        workspaceFileManager = nil
        workspaceSettingsManager?.cleanUp()
        workspaceSettingsManager = nil
        taskManager = nil
        statePersistence = nil

        securityScopedURL?.stopAccessingSecurityScopedResource()
        securityScopedURL = nil
    }

    // MARK: - Unsaved Changes

    func hasUnsavedChanges() -> Bool {
        let editedFiles = editorManager?.editorLayout
            .gatherOpenFiles()
            .compactMap(\.fileDocument)
            .filter(\.isDocumentEdited) ?? []
        return !editedFiles.isEmpty
    }

    /// Prompts the user to save any unsaved files before closing.
    /// Returns `true` if all files are clean and the workspace can close, `false` if the user cancelled.
    func promptSaveUnsavedFiles() -> Bool {
        let editedCodeFiles = editorManager?.editorLayout
            .gatherOpenFiles()
            .compactMap(\.fileDocument)
            .filter(\.isDocumentEdited) ?? []

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

        let areAllClean = editorManager?.editorLayout.gatherOpenFiles()
            .compactMap(\.fileDocument)
            .allSatisfy { !$0.isDocumentEdited } ?? true
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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
