//
//  ActivityViewer.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 21.06.24.
//

import SwiftUI

/// A view that shows the activity bar and the current status of any executed task
struct ActivityViewer: View {
    @Environment(\.colorScheme)
    var colorScheme

    var workspaceFileManager: CEWorkspaceFileManager?

    @ObservedObject var taskNotificationHandler: TaskNotificationHandler
    @ObservedObject var workspaceSettingsManager: CEWorkspaceSettings

    // TODO: try to get this from the envrionment
    @ObservedObject var taskManager: TaskManager

    init(
        workspaceFileManager: CEWorkspaceFileManager?,
        workspaceSettingsManager: CEWorkspaceSettings,
        taskNotificationHandler: TaskNotificationHandler,
        taskManager: TaskManager
    ) {
        self.workspaceFileManager = workspaceFileManager
        self.workspaceSettingsManager = workspaceSettingsManager
        self.taskNotificationHandler = taskNotificationHandler
        self.taskManager = taskManager
    }
    var body: some View {
        HStack(spacing: 0) {
            SchemeDropDownView(
                workspaceSettingsManager: workspaceSettingsManager,
                workspaceFileManager: workspaceFileManager
            )

            TaskDropDownView(taskManager: taskManager)

            Spacer(minLength: 0)

            TaskNotificationView(taskNotificationHandler: taskNotificationHandler)
                .fixedSize()
        }
        .fixedSize(horizontal: false, vertical: false)
        .padding(.horizontal, 5)
        .padding(.vertical, 1.5)
        .frame(height: 22)
        .clipped()
        .background {
            if colorScheme == .dark {
                RoundedRectangle(cornerRadius: 5)
                    .opacity(0.1)
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .opacity(0.1)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Activity Viewer")
    }
}
