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
    @Published private(set) var activeNotifications: [CENotification] = []

    private var timers: [UUID: Timer] = [:]
    private let displayDuration: TimeInterval = 5.0
    private var isPaused: Bool = false
    private var isAppActive: Bool = true

    /// Whether notifications were manually shown via toolbar
    @Published private(set) var isManuallyShown: Bool = false

    /// Set of hidden notification IDs
    private var hiddenNotificationIds: Set<UUID> = []

    /// Whether any non-sticky notifications are currently hidden
    private var hasHiddenNotifications: Bool {
        activeNotifications.contains { notification in
            !notification.isSticky && !isNotificationVisible(notification)
        }
    }

    /// Whether a notification should be visible in the overlay
    func isNotificationVisible(_ notification: CENotification) -> Bool {
        if notification.isBeingDismissed {
            return true // Always show notifications being dismissed
        }
        if notification.isSticky {
            return true // Always show sticky notifications
        }
        if isManuallyShown {
            return true // Show all notifications when manually shown
        }
        // Otherwise, show if not hidden and has active timer
        return !hiddenNotificationIds.contains(notification.id) && timers[notification.id] != nil
    }

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

        // Show any pending notifications in the overlay
        notifications
            .filter { notification in
                // Only show notifications that aren't already in the overlay
                !activeNotifications.contains { $0.id == notification.id }
            }
            .forEach { notification in
                showTemporaryNotification(notification)
            }
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
            isSticky: isSticky,
            isRead: false // Always start as unread
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
        withAnimation(.easeInOut(duration: 0.3)) {
            insertNotification(notification)
            hiddenNotificationIds.remove(notification.id) // Ensure new notification is visible
            // Only start timer if notifications aren't manually shown
            if !isManuallyShown && !notification.isSticky {
                startHideTimer(for: notification)
            }
        }
    }

    /// Inserts a notification in the correct position (sticky notifications on top)
    private func insertNotification(_ notification: CENotification) {
        if notification.isSticky {
            // Find the first sticky notification (to insert before it)
            if let firstStickyIndex = activeNotifications.firstIndex(where: { $0.isSticky }) {
                // Insert at the very start of sticky group
                activeNotifications.insert(notification, at: firstStickyIndex)
            } else {
                // No sticky notifications yet, insert at the start
                activeNotifications.insert(notification, at: 0)
            }
        } else {
            // Find the first non-sticky notification
            if let firstNonStickyIndex = activeNotifications.firstIndex(where: { !$0.isSticky }) {
                // Insert at the start of non-sticky group
                activeNotifications.insert(notification, at: firstNonStickyIndex)
            } else {
                // No non-sticky notifications yet, append at the end
                activeNotifications.append(notification)
            }
        }
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
            guard let self = self else { return }
            self.timers[notification.id] = nil

            withAnimation(.easeInOut(duration: 0.3)) {
                // Hide this specific notification
                self.hiddenNotificationIds.insert(notification.id)
                self.objectWillChange.send()
            }
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
        // Only restart timers for notifications that are currently visible
        activeNotifications
            .filter { !$0.isSticky && isNotificationVisible($0) }
            .forEach { startHideTimer(for: $0) }
    }

    /// Dismisses a specific notification
    func dismissNotification(_ notification: CENotification) {
        timers[notification.id]?.invalidate()
        timers[notification.id] = nil
        hiddenNotificationIds.remove(notification.id)
        
        if let index = activeNotifications.firstIndex(where: { $0.id == notification.id }) {
            activeNotifications[index].isBeingDismissed = true
        }
        
        withAnimation(.easeOut(duration: 0.2)) {
            activeNotifications.removeAll(where: { $0.id == notification.id })
        }
        notifications.removeAll(where: { $0.id == notification.id })
        
        // Mark as read when dismissed
        markAsRead(notification)
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

    /// Toggles visibility of notifications in the overlay
    func toggleNotificationsVisibility() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if hasHiddenNotifications || !isManuallyShown {
                // Show all notifications
                isManuallyShown = true
                hiddenNotificationIds.removeAll() // Clear all hidden states
            } else {
                // Hide all non-sticky notifications
                isManuallyShown = false
                activeNotifications
                    .filter { !$0.isSticky }
                    .forEach { hiddenNotificationIds.insert($0.id) }
            }
            objectWillChange.send()
        }
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
