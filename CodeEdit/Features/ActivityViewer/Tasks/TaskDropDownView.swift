//
//  TaskDropDownView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 24.06.24.
//

import SwiftUI

struct TasksDropDownMenuView: View {
    @Environment(\.colorScheme)
    private var colorScheme

    @ObservedObject var taskManager: TaskManager

    @State private var taskStatus: [UUID: CETaskStatus] = [:]
    @State private var isTaskPopOverPresented: Bool = false
    @State private var isHoveringTasks: Bool = false

    var projectSettings: CEWorkspaceSettingsData.ProjectSettings?
    var tasksSettings: CEWorkspaceSettingsData.TasksSettings?

    var body: some View {
        Group {
            if let selectedTask = taskManager.selectedTask {
                if let selectedActiveTask = taskManager.activeTasks[selectedTask.id] {
                    CurrentTaskOverView(activeTask: selectedActiveTask)
                } else {
                    HStack(spacing: 3) {
                        Image(systemName: "gearshape")
                            .imageScale(.medium)

                        if taskManager.availableTasks.isEmpty {
                            Text("Create Tasks")
                                .font(.subheadline)
                        } else {
                            Text(taskManager.selectedTask?.name ?? "Unknown")
                                .font(.subheadline)
                        }

                        if let taskID = taskManager.selectedTaskID {
                            Circle()
                                .fill(taskManager.taskStatus(taskID).color)
                                .frame(width: 5, height: 5)
                        } else {
                            Circle()
                                .fill(CETaskStatus.stopped.color)
                                .frame(width: 5, height: 5)
                        }
                    }
                }
            } else {
                Text("Create Tasks")
                    .font(.subheadline)
            }
        }
        .font(.caption)
        .padding(.trailing, 9)
        .padding(5)
        .background {
            Color(nsColor: colorScheme == .dark ? .white : .black)
                .opacity(isHoveringTasks || isTaskPopOverPresented ? 0.05 : 0)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 4, height: 4)))
            HStack {
                Spacer()
                if isHoveringTasks || isTaskPopOverPresented {
                    VStack(spacing: 1) {
                        Image(systemName: "chevron.down")
                    }
                    .font(.system(size: 8, weight: .bold, design: .default))
                    .padding(.top, 0.5)
                    .padding(.trailing, 3)
                }
            }
        }
        .onHover(perform: { hovering in
            self.isHoveringTasks = hovering
        })
        .popover(isPresented: $isTaskPopOverPresented) {
            VStack(alignment: .leading, spacing: 0) {
                if let tasks = tasksSettings?.items, !tasks.isEmpty {
                    ForEach(tasks, id: \.name) { item in
                        TasksPopoverView(
                            taskManager: taskManager,
                            taskStatus: taskStatus,
                            item: item
                        )
                    }
                    Divider()
                        .padding(.vertical, 5)
                }

                Group {
                    OptionMenuItemView(label: "Add Task..") {
                        NSApp.sendAction(
                            #selector(CodeEditWindowController.openWorkspaceSettings(_:)), to: nil, from: nil
                        )
                    }
                    OptionMenuItemView(label: "Manage Tasks...") {
                        NSApp.sendAction(
                            #selector(CodeEditWindowController.openWorkspaceSettings(_:)), to: nil, from: nil
                        )
                    }
                }
            }
            .padding(5)
            .frame(width: 215)
        }
        .onTapGesture {
            self.isTaskPopOverPresented.toggle()
        }
        .onReceive(taskManager.$activeTasks, perform: { activeTasks in
            taskStatus.removeAll()
            for (key, value) in activeTasks {
                taskStatus[key] = value.status
            }
        })
    }
}

struct CurrentTaskOverView: View {
    @ObservedObject var activeTask: CEActiveTask
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "gearshape")
                .imageScale(.medium)

            Text(activeTask.task.name)
                    .font(.subheadline)

            Circle()
                .fill(activeTask.status.color)
                .frame(width: 5, height: 5)
        }
        .font(.caption)
    }
}

struct TasksPopoverView: View {
    @Environment(\.dismiss)
    private var dismiss

    @ObservedObject var taskManager: TaskManager

    var taskStatus: [UUID: CETaskStatus] = [:]
    var item: CETask

    var body: some View {
        HStack {
            if taskManager.selectedTaskID == item.id {
                Image(systemName: "checkmark")
                    .imageScale(.small)
                    .frame(width: 10)
            } else {
                Spacer()
                    .frame(width: 18)
            }
            Image(systemName: "gearshape")
                .imageScale(.medium)
            Text(item.name)

            Spacer()

            Circle()
                .fill(taskManager.taskStatus(item.id).color)
                .frame(width: 5, height: 5)
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .modifier(DropdownMenuItemStyleModifier())
        .onTapGesture {
            taskManager.selectedTaskID = item.id
            dismiss()
        }
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
