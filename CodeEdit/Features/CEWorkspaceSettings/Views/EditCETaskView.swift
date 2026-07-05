//
//  EditCETaskView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 01.07.24.
//

import SwiftUI
import CodeEditCore

struct EditCETaskView: View {
    @Environment(\.dismiss)
    var dismiss

    @EnvironmentObject var workspaceSettingsManager: CEWorkspaceSettings
    @EnvironmentObject var taskManager: TaskManager

    /// A self-owned draft of the task being edited. Committed back into the settings on "Done".
    /// Editing a draft (rather than binding into `settings.tasks` by index) avoids an
    /// out-of-bounds crash when the underlying array changes — e.g. on delete.
    @State private var task: CETask
    private let taskID: UUID

    init(task: CETask) {
        self._task = State(initialValue: task)
        self.taskID = task.id
    }

    var body: some View {
        VStack(spacing: 0) {
            CETaskFormView(task: $task)
            Divider()
            HStack {
                Button(role: .destructive) {
                    do {
                        workspaceSettingsManager.settings.tasks.removeAll(where: {
                            $0.id == taskID
                        })
                        try workspaceSettingsManager.savePreferences()
                        taskManager.deleteTask(taskID: taskID)
                        self.dismiss()
                    } catch {
                        NSAlert(error: error).runModal()
                    }
                } label: {
                    Text("Delete")
                        .foregroundStyle(.red)
                        .frame(minWidth: 56)
                }

                Spacer()

                Button {
                    do {
                        if let index = workspaceSettingsManager.settings.tasks.firstIndex(where: {
                            $0.id == taskID
                        }) {
                            workspaceSettingsManager.settings.tasks[index] = task
                        }
                        try workspaceSettingsManager.savePreferences()
                        self.dismiss()
                    } catch {
                        NSAlert(error: error).runModal()
                    }
                } label: {
                    Text("Done")
                        .frame(minWidth: 56)
                }
                .buttonStyle(.borderedProminent)
                .disabled(task.isInvalid)
            }
            .padding()
        }
    }
}

// #Preview {
    //    EditCETaskView()
// }
