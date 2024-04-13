//
//  CETaskFormView.swift
//  CodeEdit
//
//  Created by Axel Martinez on 12/4/24.
//

import SwiftUI

struct CETaskFormView: View {
    @Binding var task: CETask

    @State private var selectedItemId: UUID?

    var body: some View {
        Form {
            Section {
                TextField(text: $task.name) {
                    Text("Name")
                }
                Picker("Target", selection: $task.target) {
                    Text("My Mac")
                        .tag("My Mac")
                }
            }
            Section {
                TextField(text: $task.command) {
                    Text("Task")
                }
                TextField(text: $task.workingDirectory) {
                    Text("Working Directory")
                }
            }
            Section(content: {
                List(selection: $selectedItemId) {
                    ForEach($task.env) { env in
                        EnvironmentVariableListItem(
                            item: env,
                            selectedItemId: $selectedItemId,
                            deleteHandler: removeEnv
                        )
                    }
                }
                .frame(minHeight: 56)
                .overlay {
                    if task.env.isEmpty {
                        Text("No environment variables")
                            .foregroundStyle(Color(.secondaryLabelColor))
                    }
                }
                .actionBar {
                    Button {
                        self.task.env.append(EnvironmentVariable())
                    } label: {
                        Image(systemName: "plus")
                    }
                    Divider()
                    Button {
                        if let selectedItemId = selectedItemId {
                            removeEnv(id: selectedItemId)
                        }
                    } label: {
                        Image(systemName: "minus")
                    }
                    .disabled(selectedItemId == nil)
                }
            }, header: {
                Text("Environment Variables")
            })
        }
        .formStyle(.grouped)
    }

    func removeEnv(id: UUID) {
        self.task.env.removeAll(where: {
            $0.id == id
        })
    }
}
