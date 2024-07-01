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
    @ObservedObject var workspaceSettings: CEWorkspaceSettings

    // TODO: try to get this from the envrionment
    @ObservedObject var taskManager: TaskManager

    init(
        workspaceFileManager: CEWorkspaceFileManager?,
        workspaceSettings: CEWorkspaceSettings,
        taskNotificationHandler: TaskNotificationHandler,
        taskManager: TaskManager
    ) {
        self.workspaceFileManager = workspaceFileManager
        self.workspaceSettings = workspaceSettings
        self.taskNotificationHandler = taskNotificationHandler
        self.taskManager = taskManager
    }
    var body: some View {
        HStack(spacing: 0) {
            SchemeDropDownView(
                workspaceSettings: workspaceSettings,
                workspaceFileManager: workspaceFileManager
            )

            TaskDropDownView(taskManager: taskManager)

            Spacer(minLength: 0)

            TaskNotificationView(taskNotificationHandler: taskNotificationHandler)
                .fixedSize()
        }
        .fixedSize(horizontal: false, vertical: false)
        .padding(.horizontal, 10)
        .background {
            if colorScheme == .dark {
                RoundedRectangle(cornerRadius: 5)
                    .opacity(0.10)
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .opacity(0.1)
            }
        }
    }
}
