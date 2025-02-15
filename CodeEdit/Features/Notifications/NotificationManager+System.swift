//
//  NotificationManager+System.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/14/24.
//

import SwiftUI
import UserNotifications

extension NotificationManager {
    /// Shows a notification in macOS Notification Center when app is in background
    func showSystemNotification(_ notification: CENotification) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.description
        content.userInfo = ["id": notification.id.uuidString]

        let request = UNNotificationRequest(
            identifier: notification.id.uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    /// Handles response from system notification
    func handleSystemNotificationResponse(id: String) {
        if let uuid = UUID(uuidString: id),
           let notification = notifications.first(where: { $0.id == uuid }) {
            notification.action()
            dismissNotification(notification)
        }
    }
}
