//
//  EditCETaskView.swift
//  CodeEdit
//
//  Created by Axel Martinez on 12/4/24.
//

import SwiftUI
import Collections

struct EditCETaskView: View {
    @Environment(\.dismiss)
    var dismiss

    @Binding var task: CETask
    @Binding var settings: CEWorkspaceSettingsData.TasksSettings

    var body: some View {
        VStack(spacing: 0) {
            CETaskFormView(
                task: $task
            )
            Spacer()
            Divider()
            HStack {
                Button("Remove...") {
                    self.settings.items.removeAll(where: {
                        $0.id == self.task.id
                    })
                    self.dismiss()
                }
                Spacer()
                Button("Done") {
                    self.dismiss()
                }
                .disabled(task.isInvalid)
            }
            .padding()
        }
    }
}
