//
//  WorkspaceFactory.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 07.04.26.
//

import CESourceControl
import Foundation
import CEWorkspaceFileManager
import CEEditor
import CESearch

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
    static func populate(_ workspace: Workspace, url: URL, dependencies: AppDependencies) {
        // Begin security-scoped access on the original (possibly bookmark-derived) URL so a
        // sandboxed build can read a workspace opened from recents. `startAccessingSecurityScopedResource`
        // returns `false` for non-scoped URLs (e.g. from the open panel / Powerbox), which access
        // fine without it. Released in `Workspace.tearDown`.
        if url.startAccessingSecurityScopedResource() {
            workspace.securityScopedURL = url
        }

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

        let shellClient = dependencies.shellClient
        let eventBus = dependencies.eventBus
        let sourceControlManager = SourceControlManager(
            workspaceURL: url,
            shellClient: shellClient,
            eventBus: eventBus
        )

        let workspaceFileManager = CEWorkspaceFileManager(
            folderUrl: url,
            ignoredFilesAndFolders: ignoredFilesAndDirectories,
            eventBus: eventBus
        )

        workspace.sourceControlManager = sourceControlManager
        workspace.sourceControlViewModel = SourceControlViewModel()
        workspace.workspaceFileManager = workspaceFileManager

        // --- Phase 2: Independent managers ---
        workspace.searchState = SearchState(workspaceURL: url, eventBus: eventBus)
        workspace.openQuicklyViewModel = OpenQuicklyViewModel(fileURL: url)
        workspace.commandsPaletteState = QuickActionsViewModel(commandManager: dependencies.commandManager)
        workspace.workspaceSettingsManager = CEWorkspaceSettings(workspaceURL: url)
        if let workspaceSettingsManager = workspace.workspaceSettingsManager {
            workspace.taskManager = TaskManager(
                settingsStore: workspaceSettingsManager,
                workspaceURL: url,
                eventBus: eventBus
            )
        }
        workspace.taskNotificationHandler.workspaceURL = url

        // --- Phase 3: Observer registration ---
        workspaceFileManager.addObserver(workspace.undoRegistration)
        workspace.undoRegistration.editorManager = editorManager

        // --- Phase 4: State restoration ---
        if let statePersistence = workspace.statePersistence {
            editorManager.restoreFromState(
                statePersistence: statePersistence,
                fileManager: workspaceFileManager,
                findReplaceQuery: workspace.searchState?.query
            )
            workspace.utilityAreaModel?.restoreFromState(statePersistence)
        }
    }
}
