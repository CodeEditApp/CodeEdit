//
//  NotificationManager+Delegate.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/14/24.
//

import UserNotifications

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if let id = response.notification.request.content.userInfo["id"] as? String {
            DispatchQueue.main.async {
                self.handleSystemNotificationResponse(id: id)
            }
        }
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Don't show system notifications when app is active
        completionHandler([])
    }
}
