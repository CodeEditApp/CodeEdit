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
                    TaskView(activeTask: selectedActiveTask, isCompact: true)
                } else {
                    DefaultTaskView(task: selectedTask)
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
                    TasksPopoverView(taskManager: taskManager, task: task)
                        .frame(maxWidth: .infinity)
                }
                Divider()
                    .padding(.vertical, 5)
            }

            Group {
                OptionMenuItemView(label: "Add Task...") {
                    NSApp.sendAction(#selector(CodeEditWindowController.openWorkspaceSettings(_:)), to: nil, from: nil)
                }
                OptionMenuItemView(label: "Manage Tasks...") {
                    NSApp.sendAction(#selector(CodeEditWindowController.openWorkspaceSettings(_:)), to: nil, from: nil)
                }
            }
        }
        .font(.subheadline)
        .padding(5)
        .frame(width: 215)
    }

    private struct DefaultTaskView: View {
        @ObservedObject var task: CETask
        var body: some View {
            HStack(spacing: 5) {
                Image(systemName: "gearshape")
                    .imageScale(.medium)
                Text(task.name)
                Spacer(minLength: 0)
            }
            .padding(.trailing, 7.5)
            .overlay(alignment: .trailing) {
                Circle()
                    .fill(CETaskStatus.notRunning.color)
                    .frame(width: 5, height: 5)
                    .padding(.trailing, 2.5)
            }
            .font(.subheadline)
        }
    }
}

// We need to observe each active task individually because:
// 1. Active tasks are nested inside TaskManager.
// 2. Reference types (like objects) do not notify observers when their internal state changes.
/// `TaskView` represents a single active task and observes its state.
/// - Parameter activeTask: The active task to be displayed and observed.
/// - Parameter isCompact: Determines the layout style of the view.
///   Set to `true` for a compact display, used for the current task in the activity viewer.
///   Set to `false`, used in the popover.
struct TaskView: View {
    @ObservedObject var activeTask: CEActiveTask
    // This property allows for compact layout adjustment
    var isCompact: Bool

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "gearshape")
                .imageScale(.medium)
            Text(activeTask.task.name)
            Spacer()
        }
        .padding(.trailing, 7.5)
        .overlay(alignment: .trailing) {
            Circle()
                .fill(activeTask.status.color)
                .frame(width: 5, height: 5)
                .padding(.trailing, 2.5)
        }
        .font(.subheadline)
    }
}

struct TasksPopoverView: View {
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
                TaskView(activeTask: activeTask, isCompact: true)
            } else {
                defaultTaskView
            }
        }
    }

    private var defaultTaskView: some View {
        HStack(spacing: 5) {
            Image(systemName: "gearshape")
                .imageScale(.medium)
            Text(task.name)
            Spacer()
        }
        .padding(.trailing, 7.5)
        .overlay(alignment: .trailing) {
            Circle()
                .fill(taskManager.taskStatus(taskID: task.id).color)
                .frame(width: 5, height: 5)
                .padding(.trailing, 2.5)
        }
        .font(.subheadline)
    }
}
