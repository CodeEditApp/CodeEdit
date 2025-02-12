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
/// - Displaying temporary notifications in the app UI
/// - Managing notification persistence
/// - Handling system notifications when app is in background
/// - Tracking notification read status
final class NotificationManager: NSObject, ObservableObject {
    /// Shared instance for accessing the notification manager
    static let shared = NotificationManager()

    /// Collection of all notifications, both read and unread
    @Published private(set) var notifications: [CENotification] = []

    /// Currently displayed notifications in the overlay
    @Published private(set) var activeNotification: CENotification?
    @Published private(set) var activeNotifications: [CENotification] = []

    private var timers: [UUID: Timer] = [:]
    private let displayDuration: TimeInterval = 5.0
    private var isPaused: Bool = false
    private var isAppActive: Bool = true
    private var hiddenStickyNotifications: [CENotification] = []
    private var hiddenNonStickyNotifications: [CENotification] = []
    private var dismissedNotificationIds: Set<UUID> = [] // Track dismissed notifications

    override private init() {
        super.init()

        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }

        // Set up notification center delegate
        UNUserNotificationCenter.current().delegate = self

        // Observe app active state
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidResignActive),
            name: NSApplication.didResignActiveNotification,
            object: nil
        )
    }

    @objc
    private func applicationDidBecomeActive() {
        isAppActive = true
    }

    @objc
    private func applicationDidResignActive() {
        isAppActive = false
    }

    /// Number of unread notifications
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    /// Whether there are currently notifications being displayed in the overlay
    var hasActiveNotification: Bool {
        !activeNotifications.isEmpty
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
            isSticky: isSticky
        )

        DispatchQueue.main.async { [weak self] in
            self?.notifications.append(notification)

            if self?.isAppActive == true {
                self?.showTemporaryNotification(notification)
            } else {
                self?.showSystemNotification(notification)
            }
        }
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

        DispatchQueue.main.async { [weak self] in
            self?.notifications.append(notification)

            if self?.isAppActive == true {
                self?.showTemporaryNotification(notification)
            } else {
                self?.showSystemNotification(notification)
            }
        }
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

        DispatchQueue.main.async { [weak self] in
            self?.notifications.append(notification)

            if self?.isAppActive == true {
                self?.showTemporaryNotification(notification)
            } else {
                self?.showSystemNotification(notification)
            }
        }
    }

    /// Shows a notification in macOS Notification Center when app is in background
    private func showSystemNotification(_ notification: CENotification) {
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

    /// Shows a notification in the app's overlay UI
    private func showTemporaryNotification(_ notification: CENotification) {
        activeNotifications.insert(notification, at: 0) // Add to start of array

        guard !notification.isSticky else { return }

        startHideTimer(for: notification)
    }

    /// Starts the timer to automatically hide a non-sticky notification
    private func startHideTimer(for notification: CENotification) {
        timers[notification.id]?.invalidate()
        timers[notification.id] = nil

        guard !isPaused else { return }

        timers[notification.id] = Timer.scheduledTimer(
            withTimeInterval: displayDuration,
            repeats: false
        ) { [weak self] _ in
            self?.hideNotification(notification)
        }
    }

    /// Pauses all auto-hide timers
    func pauseTimer() {
        isPaused = true
        timers.values.forEach { $0.invalidate() }
    }

    /// Resumes all auto-hide timers
    func resumeTimer() {
        isPaused = false
        activeNotifications
            .filter { !$0.isSticky }
            .forEach { startHideTimer(for: $0) }
    }

    /// Hides a specific notification
    private func hideNotification(_ notification: CENotification) {
        timers[notification.id]?.invalidate()
        timers[notification.id] = nil
        activeNotifications.removeAll(where: { $0.id == notification.id })
    }

    /// Dismisses a specific notification
    func dismissNotification(_ notification: CENotification) {
        hideNotification(notification)
        dismissedNotificationIds.insert(notification.id) // Track dismissed notification
        notifications.removeAll(where: { $0.id == notification.id })
    }

    /// Marks a notification as read
    /// - Parameter notification: The notification to mark as read
    func markAsRead(_ notification: CENotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
    }

    /// Handles response from system notification
    /// - Parameter id: ID of the notification that was interacted with
    func handleSystemNotificationResponse(id: String) {
        if let uuid = UUID(uuidString: id),
           let notification = notifications.first(where: { $0.id == uuid }) {
            notification.action()
            dismissNotification(notification)
        }
    }

    /// Hides all notifications from the overlay view
    func hideOverlayNotifications() {
        dismissedNotificationIds.removeAll() // Clear dismissed tracking when hiding
        hiddenStickyNotifications = activeNotifications.filter { $0.isSticky }
        hiddenNonStickyNotifications = activeNotifications.filter { !$0.isSticky }
        activeNotifications.removeAll()
    }

    /// Restores only sticky notifications to the overlay
    func restoreOverlayStickies() {
        // Only restore sticky notifications that weren't dismissed
        let nonDismissedStickies = hiddenStickyNotifications.filter { !dismissedNotificationIds.contains($0.id) }
        activeNotifications.insert(contentsOf: nonDismissedStickies, at: 0)
        hiddenStickyNotifications.removeAll()
        dismissedNotificationIds.removeAll() // Clear tracking after restore
    }
}

// MARK: - UNUserNotificationCenterDelegate

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
