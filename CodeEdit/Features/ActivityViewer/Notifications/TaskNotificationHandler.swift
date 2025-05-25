//
//  TaskNotificationHandler.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 21.06.24.
//

import Foundation
import Combine

/// Manages task-related notifications.
///
/// This class listens for notifications named `.taskNotification` and performs actions
/// such as creating, updating, or deleting tasks based on the notification's content.
///
/// When a task is created, it is added to the end of the array. The activity viewer displays
/// only the first item in the array. To immediately display a notification, use the 
/// `"action": "createWithPriority"` option to insert the task at the beginning of the array.
/// *Note: This option should be reserved for important notifications only.*
///
/// It is recommended to use `UUID().uuidString` to generate a unique identifier for each task.
/// This identifier can then be used to update or delete the task. Alternatively, you can use any
/// unique identifier, such as a token sent from a language server.
///
/// Remember to manage your task notifications appropriately. You should either delete task 
/// notifications manually or schedule their deletion in advance using the `deleteWithDelay` method.
///
/// ## Available Methods
/// - `create`:
///     Creates a new Task Notification. 
///     Required fields: `id` (String), `action` (String), `title` (String). 
///     Optional fields: `message` (String), `percentage` (Double), `isLoading` (Bool).
/// - `createWithPriority`:
///     Creates a new Task Notification and inserts it at the start of the array.
///     This ensures it appears in the activity viewer even if there are other task notifications before it.
///     **Note:** This should only be used for important notifications!
///     Required fields: `id` (String), `action` (String), `title` (String). 
///     Optional fields: `message` (String), `percentage` (Double), `isLoading` (Bool).
/// - `update`:
///     Updates an existing task notification. It's important to pass the same `id` to update the correct task.
///     Required fields: `id` (String), `action` (String). 
///     Optional fields: `title` (String), `message` (String), `percentage` (Double), `isLoading` (Bool).
/// - `delete`:
///     Deletes an existing task notification.
///     Required fields: `id` (String), `action` (String).
/// - `deleteWithDelay`:
///     Deletes an existing task notification after a certain `TimeInterval`.
///     Required fields: `id` (String), `action` (String), `delay` (Double).
///     **Important:** When specifying the delay, ensure it's a double. 
///     For example, '2' would be invalid because it would count as an integer, use '2.0' instead.
///
/// ## Example Usage:
/// ```swift
/// let uuidString = UUID().uuidString
///
/// func createTask() {
///     let userInfo: [String: Any] = [
///         "id": "uniqueTaskID",
///         "action": "create",
///         "title": "Task Title"
///     ]
///     NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: userInfo)
/// }
///
/// func createTaskWithPriority() {
///     let userInfo: [String: Any] = [
///         "id": "uniqueTaskID",
///         "action": "createWithPriority",
///         "title": "Priority Task Title"
///     ]
///     NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: userInfo)
/// }
///
/// func updateTask() {
///     var userInfo: [String: Any] = [
///         "id": "uniqueTaskID",
///         "action": "update",
///         "title": "Updated Task Title",
///         "message": "Updated Task Message",
///         "percentage": 0.5,
///         "isLoading": true
///     ]
///     NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: userInfo)
/// }
///
/// func deleteTask() {
///     let userInfo: [String: Any] = [
///         "id": "uniqueTaskID",
///         "action": "delete"
///     ]
///     NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: userInfo)
/// }
///
/// func deleteTaskWithDelay() {
///     let userInfo: [String: Any] = [
///         "id": "uniqueTaskID",
///         "action": "deleteWithDelay",
///         "delay": 4.0 // 4 would be invalid, because it would count as an int
///     ]
///     NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: userInfo)
/// }
/// ```
///
/// - Important: Please refer to ``CodeEdit/TaskNotificationModel`` and ensure you pass the correct values.
final class TaskNotificationHandler: ObservableObject {
    @Published private(set) var notifications: [TaskNotificationModel] = []
    var cancellables: Set<AnyCancellable> = []

    /// Initialises a new `TaskNotificationHandler` and starts observing for task notifications.
    init() {
        NotificationCenter.default
            .publisher(for: .taskNotification)
            .receive(on: DispatchQueue.main)
            .sink { notification in
                self.handleNotification(notification)
            }
            .store(in: &cancellables)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .taskNotification, object: nil)
    }

    /// Handles notifications about task events.
    ///
    /// - Parameter notification: The notification containing task information.
    private func handleNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let taskID = userInfo["id"] as? String,
              let action = userInfo["action"] as? String else { return }

        switch action {
        case "create", "createWithPriority":
            createTask(task: userInfo)
        case "update":
            updateTask(task: userInfo)
        case "delete":
            deleteTask(taskID: taskID)
        case "deleteWithDelay":
            if let delay = userInfo["delay"] as? Double {
                deleteTaskAfterDelay(taskID: taskID, delay: delay)
            }
        default:
            break
        }
    }

    /// Creates a new task or inserts it at the beginning of the tasks array based on the action.
    ///
    /// - Parameter task: A dictionary containing task information.
    private func createTask(task: [AnyHashable: Any]) {
        guard let title = task["title"] as? String,
              let id = task["id"] as? String,
              let action = task["action"] as? String else {
            return
        }

        let task = TaskNotificationModel(
            id: id,
            title: title,
            message: task["message"] as? String,
            percentage: task["percentage"] as? Double,
            isLoading: task["isLoading"] as? Bool ?? false
        )

        if action == "create" {
            notifications.append(task)
        } else {
            notifications.insert(task, at: 0)
        }
    }

    /// Updates an existing task with new information.
    ///
    /// - Parameter task: A dictionary containing task information.
    private func updateTask(task: [AnyHashable: Any]) {
        guard let taskID = task["id"] as? String else { return }
            if let index = self.notifications.firstIndex(where: { $0.id == taskID }) {
                if let title = task["title"] as? String {
                    self.notifications[index].title = title
                }
                if let message = task["message"] as? String {
                    self.notifications[index].message = message
                }
                if let percentage = task["percentage"] as? Double {
                    self.notifications[index].percentage = percentage
                }
                if let isLoading = task["isLoading"] as? Bool {
                    self.notifications[index].isLoading = isLoading
                }
            }
    }

    private func deleteTask(taskID: String) {
            self.notifications.removeAll { $0.id == taskID }
    }

    private func deleteTaskAfterDelay(taskID: String, delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.notifications.removeAll { $0.id == taskID }
        }
    }
}

extension Notification.Name {
    static let taskNotification = Notification.Name("taskNotification")
}
