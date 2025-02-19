//
//  NotificationManager.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/10/24.
//

import SwiftUI
import Combine
import UserNotifications

/// Manages the application's notification system, handling both in-app notifications and system notifications.
/// This class is responsible for:
/// - Managing notification persistence
/// - Tracking notification read status
/// - Broadcasting notifications to workspaces
final class NotificationManager: NSObject, ObservableObject {
    /// Shared instance for accessing the notification manager
    static let shared = NotificationManager()

    /// Collection of all notifications, both read and unread
    @Published private(set) var notifications: [CENotification] = []

    private var isAppActive: Bool = true

    /// Number of unread notifications
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    /// Posts a new notification
    /// - Parameters:
    ///   - iconSymbol: SF Symbol or CodeEditSymbol name for the notification icon
    ///   - iconColor: Color for the icon
    ///   - title: Main notification title
    ///   - description: Detailed notification message
    ///   - actionButtonTitle: Title for the action button
    ///   - action: Closure to execute when action button is clicked
    ///   - isSticky: Whether the notification should persist until manually dismissed
    func post(
        iconSymbol: String,
        iconColor: Color? = Color(.systemBlue),
        title: String,
        description: String,
        actionButtonTitle: String,
        action: @escaping () -> Void,
        isSticky: Bool = false
    ) {
        let notification = CENotification(
            iconSymbol: iconSymbol,
            iconColor: iconColor,
            title: title,
            description: description,
            actionButtonTitle: actionButtonTitle,
            action: action,
            isSticky: isSticky,
            isRead: false
        )

        postNotification(notification)
    }

    /// Posts a new notification
    /// - Parameters:
    ///   - iconImage: Image for the notification icon
    ///   - title: Main notification title
    ///   - description: Detailed notification message
    ///   - actionButtonTitle: Title for the action button
    ///   - action: Closure to execute when action button is clicked
    ///   - isSticky: Whether the notification should persist until manually dismissed
    func post(
        iconImage: Image,
        title: String,
        description: String,
        actionButtonTitle: String,
        action: @escaping () -> Void,
        isSticky: Bool = false
    ) {
        let notification = CENotification(
            iconImage: iconImage,
            title: title,
            description: description,
            actionButtonTitle: actionButtonTitle,
            action: action,
            isSticky: isSticky
        )

        postNotification(notification)
    }

    /// Posts a new notification
    /// - Parameters:
    ///   - iconText: Text or emoji for the notification icon
    ///   - iconTextColor: Color of the text/emoji (defaults to primary label color)
    ///   - iconColor: Background color for the icon
    ///   - title: Main notification title
    ///   - description: Detailed notification message
    ///   - actionButtonTitle: Title for the action button
    ///   - action: Closure to execute when action button is clicked
    ///   - isSticky: Whether the notification should persist until manually dismissed
    func post(
        iconText: String,
        iconTextColor: Color? = nil,
        iconColor: Color? = Color(.systemBlue),
        title: String,
        description: String,
        actionButtonTitle: String,
        action: @escaping () -> Void,
        isSticky: Bool = false
    ) {
        let notification = CENotification(
            iconText: iconText,
            iconTextColor: iconTextColor,
            iconColor: iconColor,
            title: title,
            description: description,
            actionButtonTitle: actionButtonTitle,
            action: action,
            isSticky: isSticky
        )

        postNotification(notification)
    }

    /// Dismisses a specific notification
    func dismissNotification(_ notification: CENotification) {
        notifications.removeAll(where: { $0.id == notification.id })
        markAsRead(notification)

        // Remove system notification if it exists
        removeSystemNotification(notification)

        NotificationCenter.default.post(
            name: .init("NotificationDismissed"),
            object: notification
        )
    }

    /// Marks a notification as read
    /// - Parameter notification: The notification to mark as read
    func markAsRead(_ notification: CENotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
    }

    override init() {
        super.init()
        setupNotificationDelegate()

        // Observe app active state
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidResignActive),
            name: NSApplication.didResignActiveNotification,
            object: nil
        )
    }

    @objc
    private func handleAppDidBecomeActive() {
        isAppActive = true
        // Remove any system notifications when app becomes active
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    @objc
    private func handleAppDidResignActive() {
        isAppActive = false
    }

    /// Posts a notification to workspaces and system
    private func postNotification(_ notification: CENotification) {
        DispatchQueue.main.async { [weak self] in
            self?.notifications.append(notification)

            // Always notify workspaces of new notification
            NotificationCenter.default.post(
                name: .init("NewNotificationAdded"),
                object: notification
            )

            // Additionally show system notification when app is in background
            if self?.isAppActive != true {
                self?.showSystemNotification(notification)
            }
        }
    }
}
