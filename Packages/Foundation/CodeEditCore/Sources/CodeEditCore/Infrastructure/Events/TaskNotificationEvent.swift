//
//  TaskNotificationEvent.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom on 02.07.26.
//

import Foundation

/// Describes a mutation of the task-notification list shown in the activity viewer.
///
/// Published by any feature reporting long-running work (tasks, indexing,
/// package installs); consumed by `TaskNotificationHandler`.
public struct TaskNotificationEvent: Event {
    public enum Action: Sendable {
        /// Appends a new notification to the end of the list.
        case create(TaskNotificationModel)
        /// Inserts a new notification at the front of the list so it shows
        /// immediately in the activity viewer. Reserve for important notifications.
        case createWithPriority(TaskNotificationModel)
        /// Updates an existing notification by id. Only non-`nil` fields are applied.
        case update(
            id: String,
            title: String? = nil,
            message: String? = nil,
            percentage: Double? = nil,
            isLoading: Bool? = nil
        )
        /// Removes the notification with the given id.
        case delete(id: String)
        /// Removes the notification with the given id after `delay` seconds.
        case deleteWithDelay(id: String, delay: TimeInterval)
    }

    public let action: Action

    /// Restricts delivery to the workspace at this URL; `nil` reaches all workspaces.
    public let workspaceURL: URL?

    public init(_ action: Action, workspace: URL? = nil) {
        self.action = action
        self.workspaceURL = workspace
    }
}
