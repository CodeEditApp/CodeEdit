//
//  TasksCEWorkspaceSettingsView.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
//

import SwiftUI

struct TasksCEWorkspaceSettingsView: View {
    @WorkspaceSettings(\.tasks)
    var settings
    
    @WorkspaceSettings(\.accounts.sourceControlAccounts.gitAccounts)
    var tasks

    var body: some View {
        SettingsForm {
            Section {
                Toggle("Tasks", isOn: $settings.tasksEnabled)
            }
            Section {
                ForEach(tasks) {
                    
                }
            }
        }
    }
}
