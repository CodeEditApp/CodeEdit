//
//  TaskNotificationHandler.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 21.06.24.
//

import Foundation
import Combine
import CodeEditCore

/// Maintains the list of task notifications shown in the activity viewer.
///
/// Listens for ``TaskNotificationEvent`` on the ``EventBus`` and creates, updates,
/// or deletes ``TaskNotificationModel`` entries accordingly. The activity viewer
/// displays only the first item in the array; use
/// ``TaskNotificationEvent/Action/createWithPriority(_:)`` to show a notification
/// immediately.
///
/// It is recommended to use `UUID().uuidString` as the task identifier, or any
/// other unique identifier such as a token sent from a language server. Remember
/// to delete notifications when done, either manually or via
/// ``TaskNotificationEvent/Action/deleteWithDelay(id:delay:)``.
///
/// Events can be restricted to a single workspace by passing a `workspace` URL
/// when publishing; events without one are received by all workspaces.
///
/// ## Example
/// ```swift
/// let eventBus: EventBus  // injected via the initializer
///
/// eventBus.publish(TaskNotificationEvent(
///     .create(TaskNotificationModel(id: UUID().uuidString, title: "Indexing"))
/// ))
/// ```
final class TaskNotificationHandler: ObservableObject {
    @Published private(set) var notifications: [TaskNotificationModel] = []
    var workspaceURL: URL?
    var cancellables: Set<AnyCancellable> = []

    private let eventBus: EventBus

    /// Initialises a new `TaskNotificationHandler` and starts observing for task notification events.
    init(workspaceURL: URL? = nil, eventBus: EventBus) {
        self.workspaceURL = workspaceURL
        self.eventBus = eventBus

        eventBus.subscribe(TaskNotificationEvent.self)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.handle(event)
            }
            .store(in: &cancellables)
    }

    /// Applies a task notification event to the notifications array.
    private func handle(_ event: TaskNotificationEvent) {
        // If a workspace is specified and doesn't match, don't do anything with this event.
        if let workspaceURL = event.workspaceURL, workspaceURL != self.workspaceURL {
            return
        }

        switch event.action {
        case .create(let model):
            notifications.append(model)
        case .createWithPriority(let model):
            notifications.insert(model, at: 0)
        case let .update(id, title, message, percentage, isLoading):
            updateTask(id: id, title: title, message: message, percentage: percentage, isLoading: isLoading)
        case .delete(let id):
            notifications.removeAll { $0.id == id }
        case let .deleteWithDelay(id, delay):
            deleteTaskAfterDelay(taskID: id, delay: delay)
        }
    }

    /// Updates an existing task, applying only the non-`nil` fields.
    private func updateTask(id: String, title: String?, message: String?, percentage: Double?, isLoading: Bool?) {
        guard let index = notifications.firstIndex(where: { $0.id == id }) else { return }
        if let title {
            notifications[index].title = title
        }
        if let message {
            notifications[index].message = message
        }
        if let percentage {
            notifications[index].percentage = percentage
        }
        if let isLoading {
            notifications[index].isLoading = isLoading
        }
    }

    private func deleteTaskAfterDelay(taskID: String, delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.notifications.removeAll { $0.id == taskID }
        }
    }
}
