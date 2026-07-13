//
//  TaskManager.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 24.06.24.
//

import SwiftUI
import Combine
import CodeEditCore

/// This class handles the execution of tasks
@MainActor
public class TaskManager: ObservableObject {
    @Published public var activeTasks: [UUID: CEActiveTask] = [:]
    @Published public var selectedTaskID: UUID?
    @Published public var taskShowingOutput: UUID?

    private let tasksConfiguration: any TasksConfigurationProviding

    private var workspaceURL: URL?
    private var settingsListener: AnyCancellable?

    private let eventBus: EventBus

    public init(tasksConfiguration: any TasksConfigurationProviding, workspaceURL: URL?, eventBus: EventBus) {
        self.eventBus = eventBus
        self.workspaceURL = workspaceURL
        self.tasksConfiguration = tasksConfiguration

        settingsListener = tasksConfiguration.tasksPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateSelectedTaskID()
            }
    }

    public var selectedTask: CETask? {
        if let selectedTaskID {
            return availableTasks.first { $0.id == selectedTaskID }
        } else {
            if let newSelectedTask = availableTasks.first {
                Task {
                    await MainActor.run {
                        self.selectedTaskID = newSelectedTask.id
                    }
                }
                return newSelectedTask
            }
        }
        return nil
    }

    public var availableTasks: [CETask] {
        return tasksConfiguration.tasks
    }

    public func taskStatus(taskID: UUID) -> CETaskStatus {
        return self.activeTasks[taskID]?.status ?? .notRunning
    }

    public func updateSelectedTaskID() {
        guard selectedTask == nil else { return }
        selectedTaskID = availableTasks.first?.id
    }

    public func executeActiveTask() {
        guard let task = tasksConfiguration.tasks.first(where: { $0.id == selectedTaskID }) else { return }
        Task {
            await runTask(task: task)
        }
    }

    public func runTask(task: CETask) async {
        // A process can only be started once, that means we have to renew the Process and Pipe
        // but don't initialize a new object.
        if let activeTask = activeTasks[task.id] {
            activeTask.terminate()
            // Wait until the task is no longer running.
            // The termination handler is asynchronous, so we avoid a race condition using this.
            while activeTask.status == .running {
                await Task.yield()
            }
            activeTask.run(workspaceURL: workspaceURL)
        } else {
            let runningTask = CEActiveTask(task: task, eventBus: eventBus)
            runningTask.run(workspaceURL: workspaceURL)
            await MainActor.run {
                activeTasks[task.id] = runningTask
            }
        }
    }

    public func terminateActiveTask() {
        guard let taskID = selectedTaskID else {
            return
        }

        terminateTask(taskID: taskID)
    }

    /// Suspends the task associated with the given task ID.
    ///
    /// Suspending a task means that the task's execution is paused.
    /// The task will not run or consume CPU time until it is resumed.
    /// If there is no task associated with the given ID, or if the task is not currently running,
    /// this method does nothing.
    ///
    /// - Parameter taskID: The ID of the task to suspend.
    public func suspendTask(taskID: UUID) {
        if let activeTask = activeTasks[taskID] {
            activeTask.suspend()
        }
    }

    /// Resumes the task associated with the given task ID.
    ///
    /// If there is no task associated with the given ID, or if the task is not currently suspended,
    /// this method does nothing.
    ///
    /// - Parameter taskID: The ID of the task to resume.
    public func resumeTask(taskID: UUID) {
        if let activeTask = activeTasks[taskID] {
            activeTask.resume()
        }
    }

    /// Terminates the task associated with the given task ID.
    ///
    /// Terminating a task sends a SIGTERM signal to the process, which is a request to the process to stop execution.
    /// Most processes will stop when they receive a SIGTERM signal.
    /// However, a process can choose to ignore this signal.
    ///
    /// If there is no task associated with the given ID,
    /// or if the task is not currently running, this method does nothing.
    ///
    /// - Parameter taskID: The ID of the task to terminate.
    public func terminateTask(taskID: UUID) {
        if let activeTask = activeTasks[taskID] {
            activeTask.terminate()
        }
    }

    /// Interrupts the task associated with the given task ID.
    ///
    /// Interrupting a task sends a SIGINT signal to the process, which is a request to the process to stop execution.
    /// This is the same signal that is sent when you press Ctrl+C in a terminal.
    /// It's a polite request to the process to stop what it's doing and terminate.
    /// However, the process can choose to ignore this signal or handle it in a custom way.
    ///
    /// If there is no task associated with the given ID, or if the task is not currently running,
    /// this method does nothing.
    ///
    /// - Parameter taskID: The ID of the task to interrupt.
    public func interruptTask(taskID: UUID) {
        if let activeTask = activeTasks[taskID] {
            activeTask.interrupt()
        }
    }

    public func stopAllTasks() {
        for (id, _) in activeTasks {
            interruptTask(taskID: id)
        }
    }

    public func deleteTask(taskID: UUID) {
        terminateTask(taskID: taskID)
        activeTasks.removeValue(forKey: taskID)
    }
}
