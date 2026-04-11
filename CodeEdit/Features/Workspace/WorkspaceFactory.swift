//
//  WorkspaceFactory.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 07.04.26.
//

import Foundation
import Factory

/// Constructs and wires the manager/service object graph for a ``Workspace``.
///
/// This factory encapsulates the dependency ordering and cross-wiring
/// required when opening a workspace, keeping `Workspace` itself a plain state container.
enum WorkspaceFactory {

    private static let ignoredFilesAndDirectories: Set<String> = [".DS_Store"]

    /// Populates all manager properties on `workspace` for the given workspace URL.
    ///
    /// - Parameters:
    ///   - workspace: The workspace to populate. Its `editorManager`,
    ///     `statusBarViewModel`, `utilityAreaModel`, `listenerModel`,
    ///     `taskNotificationHandler`, `undoRegistration`, and `notificationPanel`
    ///     must already be initialized (they are set at declaration time).
    ///   - url: The root URL of the workspace folder.
    @MainActor
    static func populate(_ workspace: Workspace, url: URL) {
        // Normalize the URL to always end with "/"
        var url = url
        if !url.absoluteString.hasSuffix("/") {
            url = URL(filePath: url.absoluteURL.path(percentEncoded: false) + "/")
        }

        workspace.fileURL = url
        workspace.displayName = url.lastPathComponent
        workspace.statePersistence = WorkspaceStatePersistence(workspaceURL: url)

        // --- Phase 1: Source control + file manager (dependency chain) ---
        guard let editorManager = workspace.editorManager else {
            assertionFailure("EditorManager must be initialized before calling populate")
            return
        }

        let shellClient = Container.shared.shellClient()
        let sourceControlManager = SourceControlManager(
            workspaceURL: url,
            editorManager: editorManager,
            shellClient: shellClient
        )

        let workspaceFileManager = CEWorkspaceFileManager(
            folderUrl: url,
            ignoredFilesAndFolders: ignoredFilesAndDirectories,
            sourceControlManager: sourceControlManager
        )

        sourceControlManager.fileManager = workspaceFileManager

        workspace.sourceControlManager = sourceControlManager
        workspace.workspaceFileManager = workspaceFileManager

        // --- Phase 2: Independent managers ---
        workspace.searchState = SearchState(workspaceURL: url)
        workspace.openQuicklyViewModel = OpenQuicklyViewModel(fileURL: url)
        workspace.commandsPaletteState = QuickActionsViewModel()
        workspace.workspaceSettingsManager = CEWorkspaceSettings(workspaceURL: url)
        if let workspaceSettingsManager = workspace.workspaceSettingsManager {
            workspace.taskManager = TaskManager(
                workspaceSettings: workspaceSettingsManager.settings,
                workspaceURL: url
            )
        }
        workspace.taskNotificationHandler.workspaceURL = url

        // --- Phase 3: Observer registration ---
        workspaceFileManager.addObserver(workspace.undoRegistration)

        // --- Phase 4: State restoration ---
        if let statePersistence = workspace.statePersistence {
            editorManager.restoreFromState(
                statePersistence: statePersistence,
                fileManager: workspaceFileManager,
                searchState: workspace.searchState
            )
            workspace.utilityAreaModel?.restoreFromState(statePersistence)
        }
    }
}
