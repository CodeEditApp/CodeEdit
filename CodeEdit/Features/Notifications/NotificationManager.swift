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

    /// Currently displayed notification in the overlay
    @Published private(set) var activeNotification: CENotification?

    private var timer: Timer?
    private let displayDuration: TimeInterval = 5.0
    private var isPaused: Bool = false
    private var isAppActive: Bool = true

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

    /// Whether there is currently a notification being displayed in the overlay
    var hasActiveNotification: Bool {
        activeNotification != nil
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
        activeNotification = notification

        guard !notification.isSticky else { return }

        startHideTimer()
    }

    /// Starts the timer to automatically hide non-sticky notifications
    private func startHideTimer() {
        timer?.invalidate()
        timer = nil

        guard !isPaused else { return }

        timer = Timer.scheduledTimer(withTimeInterval: displayDuration, repeats: false) { [weak self] _ in
            self?.hideActiveNotification()
        }
    }

    /// Pauses the auto-hide timer (used when hovering over notification)
    func pauseTimer() {
        isPaused = true
        timer?.invalidate()
        timer = nil
    }

    /// Resumes the auto-hide timer
    func resumeTimer() {
        isPaused = false
        if activeNotification != nil && !activeNotification!.isSticky {
            startHideTimer()
        }
    }

    /// Hides the currently active notification
    func hideActiveNotification() {
        activeNotification = nil
        timer?.invalidate()
        timer = nil
    }

    /// Dismisses a specific notification
    /// - Parameter notification: The notification to dismiss
    func dismissNotification(_ notification: CENotification) {
        if activeNotification?.id == notification.id {
            hideActiveNotification()
        }
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
