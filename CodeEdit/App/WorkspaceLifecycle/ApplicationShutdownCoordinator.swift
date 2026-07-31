//
//  ApplicationShutdownCoordinator.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 12/04/26.
//

import Foundation
import CodeEditCore

/// Orchestrates application shutdown: saves workspace paths, checks for unsaved changes,
/// prompts the user to save, and terminates running tasks.
///
/// Returns `true` if shutdown should proceed, `false` if the user cancelled.
/// Language server shutdown is handled separately by the caller (AppDelegate)
/// since it's async and tied to the NSApplication reply lifecycle.
@MainActor
final class ApplicationShutdownCoordinator {

    private let windowManager: WorkspaceWindowManaging
    private let eventBus: EventBus

    init(windowManager: WorkspaceWindowManaging, eventBus: EventBus) {
        self.windowManager = windowManager
        self.eventBus = eventBus
    }

    /// - Returns: `true` if the app should proceed with termination, `false` if the user cancelled.
    func execute() -> Bool {
        let workspaces = windowManager.openWorkspaces

        // Save workspace paths for recovery on next launch
        let projects: [String] = workspaces.map { $0.fileURL.path }
        UserDefaults.standard.set(projects, forKey: AppDelegate.recoverWorkspacesKey)

        // Check for unsaved changes and prompt the user
        let hasUnsavedChanges = workspaces.contains { $0.hasUnsavedChanges() }
        if hasUnsavedChanges {
            for workspace in workspaces where !workspace.promptSaveUnsavedFiles() {
                return false // User cancelled
            }
        }

        // Terminate all running tasks across workspaces
        terminateTasks(in: workspaces)

        return true
    }

    private func terminateTasks(in workspaces: [Workspace]) {
        let taskManagers = workspaces.compactMap { $0.taskManager }

        if taskManagers.reduce(0, { $0 + $1.activeTasks.count }) > 0 {
            let task = TaskNotificationModel(
                id: "appdelegate.terminate_tasks",
                title: "Terminating Tasks",
                message: "Interrupting all running tasks before quitting...",
                isLoading: true
            )
            eventBus.publish(TaskNotificationEvent(.create(task)))

            taskManagers.forEach { $0.stopAllTasks() }

            eventBus.publish(TaskNotificationEvent(.delete(id: task.id)))
        }
    }
}
