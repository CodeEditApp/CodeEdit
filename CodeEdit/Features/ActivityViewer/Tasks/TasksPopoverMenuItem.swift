//
//  TasksPopoverMenuItem.swift
//  CodeEdit
//
//  Created by Austin Condiff on 8/4/24.
//

import SwiftUI

/// - Note: This view **cannot** use the `dismiss` environment value to dismiss the sheet. It has to negate the boolean
///         value that presented it initially.
///         See ``SwiftUI/View/instantPopover(isPresented:arrowEdge:content:)``
struct TasksPopoverMenuItem: View {
    @ObservedObject var taskManager: TaskManager
    var task: CETask
    var dismiss: () -> Void

    var body: some View {
        HStack(spacing: 5) {
            selectionIndicator
            popoverContent
        }
        .dropdownItemStyle()
        .onTapGesture(perform: selectAction)
        .accessibilityElement()
        .accessibilityLabel(task.name)
        .accessibilityAction(.default, selectAction)
        .accessibilityAddTraits(taskManager.selectedTaskID == task.id ? [.isSelected] : [])
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

    private func selectAction() {
        taskManager.selectedTaskID = task.id
        dismiss()
    }
}
