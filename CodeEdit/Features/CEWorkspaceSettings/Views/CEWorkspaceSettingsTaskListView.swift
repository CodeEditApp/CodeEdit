//
//  CEWorkspaceSettingsTaskListView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 01.07.24.
//

import SwiftUI

struct CEWorkspaceSettingsTaskListView: View {
    @EnvironmentObject var workspaceSettingsManager: CEWorkspaceSettings
    @EnvironmentObject var taskManager: TaskManager

    @ObservedObject var settings: CEWorkspaceSettingsData

    @Binding var selectedTaskID: UUID?
    @Binding var showAddTaskSheet: Bool

    var body: some View {
        if settings.tasks.isEmpty {
            Text("No tasks")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            ForEach(settings.tasks) { task in
                TaskTile(task: task)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.selectedTaskID = task.id
                        self.showAddTaskSheet = true
                    }
                    .contextMenu {
                        Button {
                            self.selectedTaskID = task.id
                            self.showAddTaskSheet = true
                        } label: {
                            Text("Edit")
                        }
                        Button {
                            settings.tasks.removeAll { $0.id == task.id }
                            try? workspaceSettingsManager.savePreferences()
                            taskManager.deleteTask(taskID: task.id)
                        } label: {
                            Text("Delete")
                        }
                    }
            }
        }
    }

    // Every task as to be observed individually
    private struct TaskTile: View {
        @ObservedObject var task: CETask
        var body: some View {
            HStack {
                Text(task.name)
                Spacer()
                Group {
                    Text(task.command)
                    Image(systemName: "chevron.right")
                }
                .font(.system(.body, design: .monospaced))
            }
        }
    }
}
