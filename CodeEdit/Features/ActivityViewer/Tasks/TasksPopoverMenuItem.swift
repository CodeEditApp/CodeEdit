//
//  TasksPopoverMenuItem.swift
//  CodeEdit
//
//  Created by Austin Condiff on 8/4/24.
//

import SwiftUI

struct TasksPopoverMenuItem: View {
    @Environment(\.dismiss)
    private var dismiss

    @ObservedObject var taskManager: TaskManager
    var task: CETask

    var body: some View {
        HStack(spacing: 5) {
            selectionIndicator
            popoverContent
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .modifier(DropdownMenuItemStyleModifier())
        .onTapGesture {
            taskManager.selectedTaskID = task.id
            dismiss()
        }
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }

    private var selectionIndicator: some View {
        Group {
            if taskManager.selectedTaskID == task.id {
                Image(systemName: "checkmark")
                    .fontWeight(.bold)
                    .imageScale(.small)
                    .frame(width: 10)
            } else {
                Spacer()
                    .frame(width: 10)
            }
        }
    }

    private var popoverContent: some View {
        Group {
            if let activeTask = taskManager.activeTasks[task.id] {
                ActiveTaskView(activeTask: activeTask)
            } else {
                TaskView(task: task, status: taskManager.taskStatus(taskID: task.id))
            }
        }
    }
}
