//
//  Workspace.swift
//  CodeEdit
//
//  Created by CodeEdit Contributors on 06.04.26.
//

import AppKit
import SwiftUI
import Foundation

/// A plain model representing an open workspace (folder).
/// Replaces `WorkspaceDocument` (NSDocument) with no framework coupling.
@MainActor
final class Workspace: ObservableObject, WorkspaceManaging {
    @Published var sortFoldersOnTop: Bool = true
    @Published var navigatorFilter: String = ""
    @Published var sourceControlFilter = false

    private(set) var fileURL: URL?
    private(set) var displayName: String = ""

    var workspaceFileManager: CEWorkspaceFileManager?
    var editorManager: EditorManager? = EditorManager()
    var statusBarViewModel: StatusBarViewModel? = StatusBarViewModel()
    var utilityAreaModel: UtilityAreaViewModel? = UtilityAreaViewModel()
    var searchState: SearchState?
    var openQuicklyViewModel: OpenQuicklyViewModel?
    var commandsPaletteState: QuickActionsViewModel?
    var listenerModel: WorkspaceNotificationModel = .init()
    var sourceControlManager: SourceControlManager?

    var taskManager: TaskManager?
    var workspaceSettingsManager: CEWorkspaceSettings?
    var taskNotificationHandler: TaskNotificationHandler = TaskNotificationHandler()

    var statePersistence: WorkspaceStatePersistence?

    var undoRegistration: UndoManagerRegistration = UndoManagerRegistration()

    var notificationPanel = NotificationPanelViewModel()

    private let ignoredFilesAndDirectory = [
        ".DS_Store"
    ]

    // MARK: - Initialization

    init(url: URL) throws {
        try initWorkspaceState(url)
    }

    /// Minimal initializer for testing. Does not set up workspace state.
    internal init() {}

    private func initWorkspaceState(_ url: URL) throws {
        var url = url
        if !url.absoluteString.hasSuffix("/") {
            url = URL(filePath: url.absoluteURL.path(percentEncoded: false) + "/")
        }

        self.fileURL = url
        self.displayName = url.lastPathComponent
        self.statePersistence = WorkspaceStatePersistence(workspaceURL: url)

        let sourceControlManager = SourceControlManager(
            workspaceURL: url,
            editorManager: editorManager!
        )

        self.workspaceFileManager = .init(
            folderUrl: url,
            ignoredFilesAndFolders: Set(ignoredFilesAndDirectory),
            sourceControlManager: sourceControlManager
        )
        self.sourceControlManager = sourceControlManager
        sourceControlManager.fileManager = workspaceFileManager
        self.searchState = SearchState(workspaceURL: url)
        self.openQuicklyViewModel = .init(fileURL: url)
        self.commandsPaletteState = .init()
        self.workspaceSettingsManager = CEWorkspaceSettings(workspaceURL: url)
        if let workspaceSettingsManager {
            self.taskManager = TaskManager(
                workspaceSettings: workspaceSettingsManager.settings,
                workspaceURL: url
            )
        }
        self.taskNotificationHandler.workspaceURL = url

        workspaceFileManager?.addObserver(undoRegistration)
        if let statePersistence {
            editorManager?.restoreFromState(
                statePersistence: statePersistence,
                fileManager: workspaceFileManager,
                searchState: searchState
            )
            utilityAreaModel?.restoreFromState(statePersistence)
        }
    }

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
        workspaceFileManager?.cleanUp()
        workspaceFileManager = nil
        workspaceSettingsManager?.cleanUp()
        workspaceSettingsManager = nil
        taskManager = nil
        statePersistence = nil
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
