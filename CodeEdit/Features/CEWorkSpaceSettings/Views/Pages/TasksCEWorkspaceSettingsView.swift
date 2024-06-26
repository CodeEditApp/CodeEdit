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
    @Binding var projectSettings: CEWorkspaceSettingsData.ProjectSettings
    @Binding var settings: CEWorkspaceSettingsData.TasksSettings

    @State private var selectedTaskId: UUID?
    @State private var addTaskSheetPresented: Bool = false

    var body: some View {
        SettingsForm {
            Section {
                TextField("Name", text: $projectSettings.projectName)
                Toggle("Tasks", isOn: $settings.enabled)
            } header: {
                Text("Workspace")
            }
            Section(
                content: {
                    if settings.items.isEmpty {
                        Text("No tasks")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(settings.items) { task in
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
            if let selectedIndex = settings.items.firstIndex(where: {
                $0.id == selectedTaskId
            }) {
                EditCETaskView(
                    task: $settings.items[selectedIndex],
                    settings: $settings
                )
            } else {
                AddCETaskView(
                    workingDirectory: workspace.fileURL?.relativePath ?? "",
                    settings: $settings
                )
            }
        })
    }
}
