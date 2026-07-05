//
//  NotificationManager+Delegate.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/14/24.
//

import AppKit
import UserNotifications

extension NotificationManager: UNUserNotificationCenterDelegate {
    // System-invoked (not guaranteed main); `nonisolated` + hop to the main actor for state.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Extract Sendable values before crossing to the main actor (UNNotificationResponse isn't Sendable).
        // Extract Sendable values; the completion handler isn't Sendable so call it here
        // (it only signals the delegate finished), and run the main-actor action work async.
        let identifier = response.notification.request.identifier
        let actionIdentifier = response.actionIdentifier
        Task { @MainActor in
            guard let notification = self.notifications.first(where: { $0.id.uuidString == identifier }) else {
                return
            }
            // Focus CodeEdit and run action if action button was clicked
            if actionIdentifier == "ACTION_BUTTON" ||
               actionIdentifier == UNNotificationDefaultActionIdentifier {
                NSApp.activate(ignoringOtherApps: true)
                notification.action()
            }

            // Remove the notification for both action and dismiss
            if actionIdentifier == "ACTION_BUTTON" ||
               actionIdentifier == UNNotificationDefaultActionIdentifier ||
               actionIdentifier == UNNotificationDismissActionIdentifier {
                self.dismissNotification(notification)
            }
        }

        completionHandler()
    }

    nonisolated func userNotificationCenter(
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
