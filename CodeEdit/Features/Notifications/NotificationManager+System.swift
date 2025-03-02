//
//  NotificationManager+System.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/14/24.
//

import Foundation
import UserNotifications

extension NotificationManager {
    /// Shows a system notification when app is in background
    func showSystemNotification(_ notification: CENotification) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.description

        if !notification.actionButtonTitle.isEmpty {
            content.categoryIdentifier = "ACTIONABLE"
        }

        let request = UNNotificationRequest(
            identifier: notification.id.uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    /// Removes a system notification
    func removeSystemNotification(_ notification: CENotification) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(
            withIdentifiers: [notification.id.uuidString]
        )
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
