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
    @EnvironmentObject var taskManger: TaskManager
    @ObservedObject var task: CETask

    let selectedTaskIndex: Int

    var body: some View {
        VStack {
            Text("Edit Task")
            CETaskFormView(task: task)
                .padding(.top)

            Spacer()
            Divider()
            HStack {
                Button("Delete") {
                    workspaceSettingsManager.settings.tasks.removeAll(where: {
                        $0.id == task.id
                    })
                    try? workspaceSettingsManager.savePreferences()
                    taskManger.deleteTask(taskID: task.id)
                    self.dismiss()
                }

                Spacer()

                Button("Done") {
                    try? workspaceSettingsManager.savePreferences()
                    self.dismiss()
                }
                .disabled(task.isInvalid)
            }
            .padding()
        }
    }
}

// #Preview {
    //    EditCETaskView()
// }
