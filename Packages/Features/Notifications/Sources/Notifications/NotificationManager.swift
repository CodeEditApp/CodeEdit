//
//  NotificationManager.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/10/24.
//

import SwiftUI
import Combine
import UserNotifications
import Factory
import CodeEditCore

/// Manages the application's notification system, handling both in-app notifications and system notifications.
/// This class is responsible for:
/// - Managing notification persistence
/// - Tracking notification read status
/// - Broadcasting notifications to workspaces
@MainActor
final class NotificationManager: NSObject, NotificationManaging {

    /// Collection of all notifications, both read and unread
    @Published public private(set) var notifications: [CENotification] = []

    /// Fires on any change to ``notifications``, including `isRead` mutations.
    public var notificationsPublisher: AnyPublisher<[CENotification], Never> {
        $notifications.eraseToAnyPublisher()
    }

    @LazyInjected(\.eventBus)
    private var eventBus

    private var isAppActive: Bool = true

    /// Dismisses a specific notification
    public func dismissNotification(_ notification: CENotification) {
        notifications.removeAll(where: { $0.id == notification.id })
        markAsRead(notification)

        // Remove system notification if it exists
        removeSystemNotification(notification)

        eventBus.publish(CENotificationEvent(.dismissed(id: notification.id)))
    }

    /// Marks a notification as read
    /// - Parameter notification: The notification to mark as read
    public func markAsRead(_ notification: CENotification) {
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

    /// Posts a notification to workspaces and system.
    ///
    /// Runs synchronously on the main actor (the class is `@MainActor` and all callers are too);
    /// the previous `DispatchQueue.main.async` hop only ensured main-thread execution, which the
    /// actor now guarantees — call order (and thus notification order) is preserved.
    public func post(_ notification: CENotification) {
        notifications.append(notification)

        // Always notify workspaces of new notification
        eventBus.publish(CENotificationEvent(.added(id: notification.id)))

        // Additionally show system notification when app is in background
        if !isAppActive {
            showSystemNotification(notification)
        }
    }
}
