//
//  TasksCEWorkspaceSettingsView.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
//

import SwiftUI

struct TasksCEWorkspaceSettingsView: View {
    let workspace: WorkspaceDocument

    // TODO: Separate Project Settings from Task Settings
    @ObservedObject var workspaceSettings: CEWorkspaceSettings

    @State private var selectedTaskId: UUID?
    @State private var addTaskSheetPresented: Bool = false

    var body: some View {
        SettingsForm {
            Section {
                TextField("Name", text: $workspaceSettings.preferences.project.projectName)
//                Toggle("Tasks", isOn: $settings.enabled)
            } header: {
                Text("Workspace")
            }
            Section(
                content: {
                    if workspaceSettings.preferences.tasks.isEmpty {
                        Text("No tasks")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(workspaceSettings.preferences.tasks) { task in
                            HStack {
                                Text(task.name)
                                Spacer()
                                Group {
                                    Text(task.command)
                                    Image(systemName: "chevron.right")
                                }
                                .font(.system(.body, design: .monospaced))
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.selectedTaskId = task.id
                                self.addTaskSheetPresented.toggle()
                            }
                        }
                    }
                }, header: {
                    Text("Tasks")
                }, footer: {
                    HStack {
                        Spacer()
                        Button("Add Task...") {
                            self.selectedTaskId = nil
                            self.addTaskSheetPresented.toggle()
                        }
                    }
                }
            )
        }
        .scrollDisabled(true)
        .sheet(isPresented: $addTaskSheetPresented, content: {
            if let selectedIndex = $workspaceSettings.preferences.tasks.firstIndex(where: {
                $0.id == selectedTaskId
            }) {
                EditCETaskView(
                    task: $workspaceSettings.preferences.tasks[selectedIndex],
                    settings: workspaceSettings
                )
            } else {
                AddCETaskView(
                    workingDirectory: workspace.fileURL?.relativePath ?? "",
                    settings: workspaceSettings
                )
            }
        })
    }
}
