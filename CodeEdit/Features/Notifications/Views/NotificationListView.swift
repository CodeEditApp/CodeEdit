//
//  NotificationListView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/10/24.
//

import SwiftUI

struct NotificationListView: View {
    @Environment(\.dismiss)
    private var dismiss

    @ObservedObject private var notificationManager = NotificationManager.shared

    @Namespace private var animation

    private var sortedNotifications: [CENotification] {
        notificationManager.notifications.sorted { first, second in
            if first.isSticky == second.isSticky {
                return first.timestamp > second.timestamp
            }
            return first.isSticky && !second.isSticky
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                if notificationManager.notifications.isEmpty {
                    Text("No notifications")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(sortedNotifications) { notification in
                        NotificationBannerView(
                            notification: notification,
                            namespace: animation,
                            onDismiss: {
                                if !notification.isSticky && notificationManager.notifications.count == 1 {
                                    dismiss()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            notificationManager.dismissNotification(notification)
                                        }
                                    }
                                } else {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        notificationManager.dismissNotification(notification)
                                    }
                                }
                            },
                            onAction: {
                                if !notification.isSticky && notificationManager.notifications.count == 1 {
                                    dismiss()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        notification.action()
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            notificationManager.dismissNotification(notification)
                                        }
                                    }
                                } else {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        notification.action()
                                        notificationManager.dismissNotification(notification)
                                    }
                                }
                            }
                        )
                        .environment(\.isOverlay, false)
                        .environment(\.isSingleListItem, notificationManager.notifications.count == 1)
                        .transition(.opacity)
                    }
                }
            }
            .padding(10)
        }
    }
}
