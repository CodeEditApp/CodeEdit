//
//  AddCETaskView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 01.07.24.
//

import SwiftUI
import CodeEditCore

struct AddCETaskView: View {
    @Environment(\.dismiss)
    var dismiss

    @EnvironmentObject var workspaceSettingsManager: CEWorkspaceSettings
    @State private var newTask = CETask(target: "My Mac")

    var body: some View {
        VStack(spacing: 0) {
            TaskFormView(task: $newTask)
            Divider()
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .frame(minWidth: 56)
                }
                Spacer()
                Button {
                    workspaceSettingsManager.settings.tasks.append(newTask)
                    try? workspaceSettingsManager.savePreferences()
                    dismiss()
                } label: {
                    Text("Save")
                        .frame(minWidth: 56)
                }
                .buttonStyle(.borderedProminent)
                .disabled(newTask.isInvalid)
            }
            .padding()
        }
        .accessibilityIdentifier("AddTaskView")
    }

}

#Preview {
    AddCETaskView()
}
