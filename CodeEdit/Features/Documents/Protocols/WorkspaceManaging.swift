//
//  WorkspaceManaging.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 06.04.26.
//

import CESourceControl
import Foundation
import CEWorkspaceFileManager
import CEEditor
import CENotifications
import CESearch
import CETerminal

/// Protocol defining the interface that workspace consumers depend on.
/// Enables testability via mock implementations and decouples views from the concrete Workspace type.
protocol WorkspaceManaging: AnyObject, ObservableObject {
    var fileURL: URL? { get }
    var displayName: String { get }
    var workspaceFileManager: CEWorkspaceFileManager? { get }
    var editorManager: EditorManager? { get }
    var statusBarViewModel: StatusBarViewModel? { get }
    var utilityAreaModel: UtilityAreaViewModel? { get }
    var searchState: SearchState? { get }
    var openQuicklyViewModel: OpenQuicklyViewModel? { get }
    var commandsPaletteState: QuickActionsViewModel? { get }
    var sourceControlManager: SourceControlManager? { get }
    var sourceControlViewModel: SourceControlViewModel? { get }
    var taskManager: TaskManager? { get }
    var workspaceSettingsManager: CEWorkspaceSettings? { get }
    var statePersistence: WorkspaceStatePersistence? { get }
    var listenerModel: WorkspaceNotificationModel { get }
    var undoRegistration: UndoManagerRegistration { get }
    var notificationPanel: NotificationPanelViewModel { get }
    var taskNotificationHandler: TaskNotificationHandler { get }
    var projectNavigatorViewModel: ProjectNavigatorViewModel? { get }
}
