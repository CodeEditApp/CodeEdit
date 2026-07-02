//
//  NotificationToolbarItem.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/10/24.
//

import SwiftUI

struct NotificationToolbarItem: View {
    @EnvironmentObject private var notificationPanel: NotificationPanelViewModel
    @Environment(\.controlActiveState)
    private var controlActiveState

    var body: some View {
        let visibleNotifications = notificationPanel.visibleNotifications

        if notificationPanel.unreadCount > 0 || !visibleNotifications.isEmpty {
            Button {
                notificationPanel.toggleNotificationsVisibility()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "bell.badge.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(controlActiveState == .inactive ? .secondary : Color.accentColor, .primary)
                    Text("\(notificationPanel.unreadCount)")
                        .monospacedDigit()
                }
            }
        }
    }
}
