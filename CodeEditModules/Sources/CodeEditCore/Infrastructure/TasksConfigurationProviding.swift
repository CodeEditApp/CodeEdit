//
//  TasksConfigurationProviding.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom on 13/07/2026.
//

import Combine

/// Provides the workspace's configured tasks to consumers that shouldn't know
/// where task configuration is stored (currently `.codeedit/settings.json`,
/// loaded by the app-side `CEWorkspaceSettings`).
public protocol TasksConfigurationProviding: AnyObject {
    /// The tasks currently configured for the workspace.
    var tasks: [CETask] { get }

    /// Emits the task list whenever the workspace configuration changes.
    var tasksPublisher: AnyPublisher<[CETask], Never> { get }
}
