//
//  TasksCommands.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/8/25.
//

import SwiftUI

struct TasksCommands: Commands {
    @UpdatingWindowController var windowController: CodeEditWindowController?

    var taskManager: TaskManager? {
        windowController?.workspace?.taskManager
    }

    var selectedTask: CETask? {
        taskManager?.availableTasks.first(where: { $0.id == taskManager?.selectedTaskID })
    }

    var body: some Commands {
        CommandMenu("Tasks") {
            let selectedTaskName: String? = if let selectedTask {
                "\"" + selectedTask.name + "\""
            } else {
                nil
            }

            Button("Run \(selectedTaskName ?? "(No Selected Task)")") {
                taskManager?.executeActiveTask()
            }
            .keyboardShortcut("r", modifiers: .command)
            .disabled(taskManager?.selectedTaskID == nil)

            Button("Stop \(selectedTaskName ?? "(No Selected Task)")") {
                taskManager?.terminateSelectedTask()
            }
            .keyboardShortcut(".", modifiers: .command)
            .disabled(taskManager?.activeTasks.isEmpty == true)

            Divider()

            Menu {
                if let taskManager {
                    ForEach(taskManager.availableTasks) { task in
                        Button(task.name) {
                            taskManager.selectedTaskID = task.id
                        }
                    }
                }
            } label: {
                Text("Choose Task...")
            }
            .disabled(taskManager?.availableTasks.isEmpty == true)

            Button("Manage Tasks...") {
                NSApp.sendAction(
                    #selector(CodeEditWindowController.openWorkspaceSettings(_:)),
                    to: windowController,
                    from: nil
                )
            }
            .disabled(windowController == nil)
        }
    }
}
