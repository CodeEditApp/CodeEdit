//
//  NotificationManager+Delegate.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/14/24.
//

import AppKit
import UserNotifications

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if let notification = notifications.first(where: {
            $0.id.uuidString == response.notification.request.identifier
        }) {
            // Focus CodeEdit and run action if action button was clicked
            if response.actionIdentifier == "ACTION_BUTTON" ||
               response.actionIdentifier == UNNotificationDefaultActionIdentifier {
                NSApp.activate(ignoringOtherApps: true)
                notification.action()
            }

            // Remove the notification for both action and dismiss
            if response.actionIdentifier == "ACTION_BUTTON" ||
               response.actionIdentifier == UNNotificationDefaultActionIdentifier ||
               response.actionIdentifier == UNNotificationDismissActionIdentifier {
                dismissNotification(notification)
            }
        }

        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    func setupNotificationDelegate() {
        UNUserNotificationCenter.current().delegate = self

        // Create action button
        let action = UNNotificationAction(
            identifier: "ACTION_BUTTON",
            title: "Action", // This will be replaced with actual button title
            options: .foreground
        )

        // Create category with action button
        let actionCategory = UNNotificationCategory(
            identifier: "ACTIONABLE",
            actions: [action],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        UNUserNotificationCenter.current().setNotificationCategories([actionCategory])
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
}
