//
//  CEWorkspaceSettingsView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 01.07.24.
//

import SwiftUI

struct CEWorkspaceSettingsView: View {
    @EnvironmentObject var workspaceSettingsManager: CEWorkspaceSettings
    @EnvironmentObject var workspace: WorkspaceDocument

    @StateObject var settingsViewModel = SettingsViewModel()

    @State var selectedTaskID: UUID?
    @State var showAddTaskSheet: Bool = false

    let window: NSWindow?
    var body: some View {
        VStack(spacing: 0) {
            SettingsForm {
                Section {
                    TextField(
                        "Name",
                        text: $workspaceSettingsManager.settings.project.projectName
                    )
                } header: {
                    Text("Workspace")
                }

                Section {
                    CEWorkspaceSettingsTaskListView(
                        settings: workspaceSettingsManager.settings,
                        selectedTaskID: $selectedTaskID,
                        showAddTaskSheet: $showAddTaskSheet
                    )
                } header: {
                    Text("Tasks")
                } footer: {
                    HStack {
                        Spacer()
                        Button {
                            selectedTaskID = nil
                            showAddTaskSheet = true
                        } label: {
                            Text("Add Task...")
                        }
                    }
                }
            }
            .scrollDisabled(true)

            Spacer()
            Divider()
            HStack {
                Spacer()
                Button("Done") {
                    window?.close()
                }
            }.padding()
        }
        .environmentObject(settingsViewModel)
        .sheet(isPresented: $showAddTaskSheet) {
            if let selectedTaskIndex = workspaceSettingsManager.settings.tasks.firstIndex(where: {
                $0.id == selectedTaskID
            }) {
                EditCETaskView(
                    task: workspaceSettingsManager.settings.tasks[selectedTaskIndex],
                    selectedTaskIndex: selectedTaskIndex
                )
            } else {
                AddCETaskView(workingDirectory: workspace.fileURL?.relativePath ?? "")
            }
        }
    }
}

#Preview {
    CEWorkspaceSettingsView(window: nil)
}
