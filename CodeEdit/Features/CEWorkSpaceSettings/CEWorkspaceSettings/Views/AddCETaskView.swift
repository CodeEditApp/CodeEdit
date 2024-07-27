//
//  AddCETaskView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 01.07.24.
//

import SwiftUI

struct AddCETaskView: View {
    @Environment(\.dismiss)
    var dismiss

    @EnvironmentObject var workspaceSettingsManager: CEWorkspaceSettings
    @StateObject var newTask: CETask

    init(workingDirectory: String) {
        self._newTask = StateObject(wrappedValue: CETask(target: "My Mac", workingDirectory: workingDirectory))
    }
    var body: some View {
        // TODO: Discuss if this is needed
        NavigationStack {
            VStack {
                CETaskFormView(
                    task: newTask
                ).padding(.top)

                Spacer()
                Divider()
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    Spacer()
                    Button("Save") {
                        workspaceSettingsManager.settings.tasks.append(newTask)
                        try? workspaceSettingsManager.savePreferences()
                        dismiss()
                    }
                    .disabled(newTask.isInvalid)
                }
                .padding()
            }.navigationTitle("Add Task")
        }
    }

}

#Preview {
    AddCETaskView(workingDirectory: "/User/")
}
