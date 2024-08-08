//
//  EditCETaskView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 01.07.24.
//

import SwiftUI

struct EditCETaskView: View {
    @Environment(\.dismiss)
    var dismiss

    @EnvironmentObject var workspaceSettingsManager: CEWorkspaceSettings
    @EnvironmentObject var taskManager: TaskManager
    @ObservedObject var task: CETask

    let selectedTaskIndex: Int

    var body: some View {
        VStack(spacing: 0) {
            CETaskFormView(task: task)
            Divider()
            HStack {
                Button(role: .destructive) {
                    workspaceSettingsManager.settings.tasks.removeAll(where: {
                        $0.id == task.id
                    })
                    try? workspaceSettingsManager.savePreferences()
                    taskManager.deleteTask(taskID: task.id)
                    self.dismiss()
                } label: {
                    Text("Delete")
                        .foregroundStyle(.red)
                        .frame(minWidth: 56)
                }

                Spacer()

                Button {
                    try? workspaceSettingsManager.savePreferences()
                    self.dismiss()
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
