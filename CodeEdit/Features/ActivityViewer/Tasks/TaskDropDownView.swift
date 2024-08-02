//
//  TaskDropDownView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 24.06.24.
//

import SwiftUI

struct TaskDropDownView: View {
    @Environment(\.colorScheme)
    private var colorScheme

    @ObservedObject var taskManager: TaskManager

    @State private var isTaskPopOverPresented: Bool = false
    @State private var isHoveringTasks: Bool = false

    var body: some View {
        Group {
            if let selectedTask = taskManager.selectedTask {
                if let selectedActiveTask = taskManager.activeTasks[selectedTask.id] {
                    ActiveTaskView(activeTask: selectedActiveTask)
                        .fixedSize()
                } else {
                    TaskView(task: selectedTask, status: CETaskStatus.notRunning)
                        .fixedSize()
                }
            } else {
                Text("Create Tasks")
            }
        }
        .font(.subheadline)
        .padding(.trailing, 11.5)
        .padding(.horizontal, 2.5)
        .padding(.vertical, 2.5)
        .background(backgroundColor)
        .onHover { hovering in
            self.isHoveringTasks = hovering
        }
        .popover(isPresented: $isTaskPopOverPresented, arrowEdge: .bottom) {
            taskPopoverContent
        }
        .onTapGesture {
            self.isTaskPopOverPresented.toggle()
        }
    }

    private var backgroundColor: some View {
        Color(nsColor: colorScheme == .dark ? .white : .black)
            .opacity(isHoveringTasks || isTaskPopOverPresented ? 0.05 : 0)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 4, height: 4)))
            .overlay(
                HStack {
                    Spacer()
                    if isHoveringTasks || isTaskPopOverPresented {
                        chevronIcon
                    }
                }
            )
    }

    private var chevronIcon: some View {
        Image(systemName: "chevron.down")
            .font(.system(size: 8, weight: .bold, design: .default))
            .padding(.top, 0.5)
            .padding(.trailing, 2)
    }

    private var taskPopoverContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !taskManager.availableTasks.isEmpty {
                ForEach(taskManager.availableTasks, id: \.id) { task in
                    TasksPopoverMenuItem(taskManager: taskManager, task: task)
                }
                Divider()
                    .padding(.vertical, 5)
            }
            OptionMenuItemView(label: "Add Task...") {
                NSApp.sendAction(#selector(CodeEditWindowController.openWorkspaceSettings(_:)), to: nil, from: nil)
            }
            OptionMenuItemView(label: "Manage Tasks...") {
                NSApp.sendAction(#selector(CodeEditWindowController.openWorkspaceSettings(_:)), to: nil, from: nil)
            }
        }
        .font(.subheadline)
        .padding(5)
        .frame(minWidth: 215)
    }
}

/// `TaskView` represents a single active task and observes its state.
/// - Parameter task: The task to be displayed and observed.
/// - Parameter status: The status of the task to be displayed.
struct TaskView: View {
    @ObservedObject var task: CETask
    var status: CETaskStatus

    var body: some View {
        HStack(spacing: 5) {
//            Label(task.name, systemImage: "gearshape")
//                .labelStyle(.titleAndIcon)
            Image(systemName: "gearshape")
            Text(task.name)
            Spacer(minLength: 0)
        }
        .padding(.trailing, 7.5)
        .overlay(alignment: .trailing) {
            Circle()
                .fill(status.color)
                .frame(width: 5, height: 5)
                .padding(.trailing, 2.5)
        }
    }
}

// We need to observe each active task individually because:
// 1. Active tasks are nested inside TaskManager.
// 2. Reference types (like objects) do not notify observers when their internal state changes.
/// `ActiveTaskView` represents a single active task and observes its state.
/// - Parameter activeTask: The active task to be displayed and observed.
struct ActiveTaskView: View {
    @ObservedObject var activeTask: CEActiveTask

    var body: some View {
        TaskView(task: activeTask.task, status: activeTask.status)
    }
}

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
