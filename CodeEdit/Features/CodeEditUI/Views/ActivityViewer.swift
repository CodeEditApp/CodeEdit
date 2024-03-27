//
//  ActivityViewer.swift
//  CodeEdit
//
//  Created by Axel Martinez on 26/1/24.
//

import SwiftUI
import Combine

/// A view that shows the activity bar and the current status of any executed task
struct ActivityViewer: View {
    private var workspaceFileManager: CEWorkspaceFileManager?

    @ObservedObject private var taskManager: TaskManager
    @State private var status: CETaskStatus = .stopped
    @State private var output: String = ""

    init(
        workspaceFileManager: CEWorkspaceFileManager?,
        taskManager: TaskManager
    ) {
        self.workspaceFileManager = workspaceFileManager
        self.taskManager = taskManager
    }

    var body: some View {
        HStack {
            HStack(spacing: 3) {
                DropdownMenu(
                    icon: "folder.badge.gearshape",
                    selectedItem: workspaceFileManager?.workspaceItem.fileName(),
                    items: {
                        WorkspaceMenuItem(
                            workspaceFileManager: workspaceFileManager,
                            item: workspaceFileManager?.workspaceItem
                        )
                    },
                    options: {
                        OptionMenuItem(label: "Add Folder..")
                        OptionMenuItem(label: "Workspace Settings...")
                    }
                )
                Image(systemName: "chevron.compact.right")
                    .imageScale(.medium)
                DropdownMenu(
                    icon: "gearshape",
                    selectedItem: taskManager.activeTask?.name,
                    status: status.color,
                    items: {
                        ForEach(taskManager.getTasks(), id: \.name) { item in
                            TaskMenuItem(item: item, taskManager: taskManager)
                        }
                    },
                    options: {
                        OptionMenuItem(label: "Add Task..")
                        OptionMenuItem(label: "Manage Tasks...")
                    }
                )
                Spacer()
                Text(output)
                    .foregroundColor(.primary)
                if let progress = taskManager.activeTaskRun?.progress, progress > 0 {
                    ring(progress: progress)
                        .frame(width: 14)
                        .animation(Animation.easeOut(duration: 2), value: true)
                        .padding(.leading, 5)
                }
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background {
                RoundedRectangle(cornerRadius: 5).opacity(0.15)
            }
            .frame(minWidth: 200, idealWidth: 900)

            HStack {
                if let errors = taskManager.activeTaskRun?.errors, errors > 0 {
                    statusLabel("xmark.octagon.fill", errors.description, Color.red)
                }
                if let warnings = taskManager.activeTaskRun?.warnings, warnings > 0 {
                    statusLabel("exclamationmark.triangle.fill", warnings.description, Color.yellow)
                }
            }
        }
        .font(.subheadline)
        .padding(.leading, -50)
        .onReceive(taskManager.activeTaskRun?.$output.eraseToAnyPublisher() ??
                   Empty().eraseToAnyPublisher()) { output in
            self.output = output
        }
        .onReceive(taskManager.activeTaskRun?.$status.eraseToAnyPublisher() ??
                   Empty().eraseToAnyPublisher()) { status in
            self.status = status
        }
    }

    @ViewBuilder
    private func ring(progress value: CGFloat) -> some View {
        let color = Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
        Circle()
            .stroke(style: StrokeStyle(lineWidth: 3))
            .foregroundStyle(.tertiary)
            .overlay {
                Circle()
                    .trim(from: 0, to: value)
                    .stroke(color.gradient, style: StrokeStyle(lineWidth: 3, lineCap: .round))
            }
            .rotationEffect(.degrees(-90))
    }

    @ViewBuilder
    private func statusLabel(_ icon: String, _ count: String, _ color: Color) -> some View {
        Label(title: {
            Text(count)
                .padding(.leading, -7)
        }, icon: {
            Image(systemName: icon)
                .imageScale(.medium)
                .symbolRenderingMode(.multicolor)
                .foregroundColor(color)
        })
        .labelStyle(.titleAndIcon)
    }

    struct WorkspaceMenuItem: View {
        var workspaceFileManager: CEWorkspaceFileManager?
        var item: CEWorkspaceFile?

        var body: some View {
            HStack {
                if workspaceFileManager?.workspaceItem.fileName() == item?.name {
                    Image(systemName: "checkmark")
                        .imageScale(.medium)
                        .frame(width: 10)
                } else {
                    Spacer()
                        .frame(width: 18)
                }
                Image(systemName: "folder.badge.gearshape")
                    .imageScale(.medium)
                Text(item?.name ?? "")
                Spacer()
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .dropdownMenuItem()
            .onTapGesture {
            }
        }
    }

    struct TaskMenuItem: View {
        var item: any CETask

        @ObservedObject var taskManager: TaskManager

        var body: some View {
            HStack {
                if taskManager.activeTask?.name == item.name {
                    Image(systemName: "checkmark")
                        .imageScale(.medium)
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
                    .fill(taskManager.activeTaskRun?.status.color ?? CETaskStatus.stopped.color)
                    .frame(width: 5, height: 5)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .dropdownMenuItem()
            .onTapGesture {
                self.taskManager.activeTask = item
            }
        }
    }

    struct OptionMenuItem: View {
        var label: String

        var body: some View {
            HStack {
                Text(label)
                Spacer()
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 28)
            .dropdownMenuItem()
        }
    }
}
