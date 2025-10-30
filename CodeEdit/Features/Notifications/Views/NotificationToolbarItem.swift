//
//  NotificationToolbarItem.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/10/24.
//

import SwiftUI

struct NotificationToolbarItem: View {
    @EnvironmentObject private var workspace: WorkspaceDocument
    @ObservedObject private var notificationManager = NotificationManager.shared
    @Environment(\.controlActiveState)
    private var controlActiveState

    var body: some View {
        let visibleNotifications = workspace.notificationPanel.visibleNotifications

        if notificationManager.unreadCount > 0 || !visibleNotifications.isEmpty {
            Button {
                workspace.notificationPanel.toggleNotificationsVisibility()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "bell.badge.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(controlActiveState == .inactive ? .secondary : Color.accentColor, .primary)
                    Text("\(notificationManager.unreadCount)")
                        .monospacedDigit()
                }
            }
        }
    }
}
