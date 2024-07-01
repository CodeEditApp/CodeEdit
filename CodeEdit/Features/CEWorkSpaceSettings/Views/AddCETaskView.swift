//
//  AddCETaskView.swift
//  CodeEdit
//
//  Created by Axel Martinez on 3/4/24.
//

import SwiftUI
import Collections

struct AddCETaskView: View {
    @Environment(\.dismiss)
    var dismiss

    @ObservedObject var settings: CEWorkspaceSettings

    @State private var task: CETask

    init(workingDirectory: String, settings: CEWorkspaceSettings) {
        self.settings = settings
        self._task = State(initialValue: CETask(
            target: "My Mac",
            workingDirectory: workingDirectory
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            CETaskFormView(
                task: $task
            )
            Spacer()
            Divider()
            HStack {
                Button("Remove...") {
                    self.dismiss()
                }
                Spacer()
                Button("Done") {
                    self.settings.preferences.tasks.append(task)
                    self.dismiss()
                }
                .disabled(task.isInvalid)
            }
            .padding()
        }
    }
}
