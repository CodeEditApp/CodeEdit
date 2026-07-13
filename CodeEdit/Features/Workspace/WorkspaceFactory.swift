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
import CENotifications
import CESearch
import CETerminal

/// Constructs and wires the manager/service object graph for a ``Workspace``.
///
/// This factory encapsulates the dependency ordering and cross-wiring
/// required when opening a workspace, keeping `Workspace` itself a plain state container.
enum WorkspaceFactory {

    private static let ignoredFilesAndDirectories: Set<String> = [".DS_Store"]

    /// Builds a fully-populated ``Workspace`` for the given folder URL.
    @MainActor
    static func make(url: URL, dependencies: AppDependencies) -> Workspace {
        // Begin security-scoped access on the original (possibly bookmark-derived) URL so a
        // sandboxed build can read a workspace opened from recents. `startAccessingSecurityScopedResource`
        // returns `false` for non-scoped URLs (e.g. from the open panel / Powerbox), which access
        // fine without it. Released in `Workspace.tearDown`.
        var securityScopedURL: URL?
        if url.startAccessingSecurityScopedResource() {
            securityScopedURL = url
        }

        // Normalize the URL to always end with "/"
        var url = url
        if !url.absoluteString.hasSuffix("/") {
            url = URL(filePath: url.absoluteURL.path(percentEncoded: false) + "/")
        }

        let eventBus = dependencies.eventBus
        let statePersistence = WorkspaceStatePersistence(workspaceURL: url)
        let editorManager = EditorManager()
        let sourceControlManager = SourceControlManager(
            workspaceURL: url,
            shellClient: dependencies.shellClient,
            eventBus: eventBus
        )
        let workspaceFileManager = CEWorkspaceFileManager(
            folderUrl: url,
            ignoredFilesAndFolders: ignoredFilesAndDirectories,
            eventBus: eventBus
        )
        let searchState = SearchState(workspaceURL: url, eventBus: eventBus)
        let workspaceSettingsManager = CEWorkspaceSettings(workspaceURL: url)
        let taskManager = TaskManager(
            tasksConfiguration: workspaceSettingsManager,
            workspaceURL: url,
            eventBus: eventBus
        )
        let undoRegistration = UndoManagerRegistration()

        // Observer registration
        workspaceFileManager.addObserver(undoRegistration)
        undoRegistration.editorManager = editorManager

        let workspace = Workspace(
            fileURL: url,
            displayName: url.lastPathComponent,
            editorManager: editorManager,
            workspaceFileManager: workspaceFileManager,
            sourceControlManager: sourceControlManager,
            sourceControlViewModel: SourceControlViewModel(),
            searchState: searchState,
            taskManager: taskManager,
            workspaceSettingsManager: workspaceSettingsManager,
            statePersistence: statePersistence,
            undoRegistration: undoRegistration,
            listenerModel: WorkspaceNotificationModel(),
            projectNavigatorViewModel: ProjectNavigatorViewModel(),
            securityScopedURL: securityScopedURL
        )

        // State restoration
        editorManager.restoreFromState(
            statePersistence: statePersistence,
            fileManager: workspaceFileManager,
            findReplaceQuery: searchState.query
        )

        return workspace
    }
}
