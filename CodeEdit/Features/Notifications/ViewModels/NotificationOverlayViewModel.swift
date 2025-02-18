//
//  NotificationOverlayViewModel.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/14/24.
//

import SwiftUI

final class NotificationOverlayViewModel: ObservableObject {
    /// Currently displayed notifications in the overlay
    @Published private(set) var activeNotifications: [CENotification] = []

    /// Whether notifications were manually shown via toolbar
    @Published private(set) var isManuallyShown: Bool = false

    /// Set of hidden notification IDs
    @Published private(set) var hiddenNotificationIds: Set<UUID> = []

    /// Timers for notifications
    private var timers: [UUID: Timer] = [:]

    /// Display duration for notifications
    private let displayDuration: TimeInterval = 5.0

    /// Whether notifications are paused
    private var isPaused: Bool = false

    private var notificationManager = NotificationManager.shared

    @Published var scrolledToTop: Bool = true

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
        return !hiddenNotificationIds.contains(notification.id)
    }

    /// Handles focus changes for the notification overlay
    func handleFocusChange(isFocused: Bool) {
        if !isFocused {
            // Only hide if manually shown and focus is completely lost
            if isManuallyShown {
                toggleNotificationsVisibility()
            }
        }
    }

    /// Toggles visibility of notifications in the overlay
    func toggleNotificationsVisibility() {
        if isManuallyShown {
            if !scrolledToTop {
                // Just set isManuallyShown to false to trigger the offset animation
                withAnimation(.easeInOut(duration: 0.3)) {
                    isManuallyShown = false
                }

                // After the slide-out animation, hide notifications
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    // Hide non-sticky notifications
                    self.activeNotifications
                        .filter { !$0.isSticky }
                        .forEach { self.hiddenNotificationIds.insert($0.id) }
                    self.objectWillChange.send()

                    // After notifications are hidden, reset scroll position
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.scrolledToTop = true
                    }
                }
            } else {
                // At top, just hide normally
                hideNotifications()
            }
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                isManuallyShown = true
                hiddenNotificationIds.removeAll()
                objectWillChange.send()
            }
        }
    }

    private func hideNotifications() {
        withAnimation(.easeInOut(duration: 0.3)) {
            self.isManuallyShown = false
            self.activeNotifications
                .filter { !$0.isSticky }
                .forEach { self.hiddenNotificationIds.insert($0.id) }
            self.objectWillChange.send()
        }
    }

    /// Starts the timer to automatically hide a notification
    func startHideTimer(for notification: CENotification) {
        guard !notification.isSticky && !isManuallyShown else { return }

        timers[notification.id]?.invalidate()
        timers[notification.id] = nil

        guard !isPaused else { return }

        timers[notification.id] = Timer.scheduledTimer(
            withTimeInterval: displayDuration,
            repeats: false
        ) { [weak self] _ in
            guard let self = self else { return }
            self.timers[notification.id] = nil

            // Ensure we're on the main thread and animate the change
            DispatchQueue.main.async {
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.3
                    context.allowsImplicitAnimation = true

                    withAnimation(.easeInOut(duration: 0.3)) {
                        var newHiddenIds = self.hiddenNotificationIds
                        newHiddenIds.insert(notification.id)
                        self.hiddenNotificationIds = newHiddenIds
                    }
                }
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

    /// Handles a new notification being added
    func handleNewNotification(_ notification: CENotification) {
        withAnimation(.easeInOut(duration: 0.3)) {
            insertNotification(notification)
            hiddenNotificationIds.remove(notification.id)
            if !isManuallyShown && !notification.isSticky {
                startHideTimer(for: notification)
            }
        }
    }

    /// Dismisses a specific notification
    func dismissNotification(_ notification: CENotification) {
        // Clean up timers
        timers[notification.id]?.invalidate()
        timers[notification.id] = nil
        hiddenNotificationIds.remove(notification.id)

        // Mark as being dismissed for animation
        if let index = activeNotifications.firstIndex(where: { $0.id == notification.id }) {
            var dismissingNotification = activeNotifications[index]
            dismissingNotification.isBeingDismissed = true
            activeNotifications[index] = dismissingNotification

            // Wait for fade animation before removing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                withAnimation(.easeOut(duration: 0.2)) {
                    self.activeNotifications.removeAll(where: { $0.id == notification.id })
                    if self.activeNotifications.isEmpty && self.isManuallyShown {
                        self.isManuallyShown = false
                    }
                }

                NotificationManager.shared.markAsRead(notification)
                NotificationManager.shared.dismissNotification(notification)
            }
        }
    }

    init() {
        // Observe new notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewNotificationAdded(_:)),
            name: .init("NewNotificationAdded"),
            object: nil
        )

        // Observe notification dismissals
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNotificationRemoved(_:)),
            name: .init("NotificationDismissed"),
            object: nil
        )

        // Load initial notifications from NotificationManager
        notificationManager.notifications.forEach { notification in
            handleNewNotification(notification)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func handleNewNotificationAdded(_ notification: Notification) {
        guard let ceNotification = notification.object as? CENotification else { return }
        handleNewNotification(ceNotification)
    }

    @objc
    private func handleNotificationRemoved(_ notification: Notification) {
        guard let ceNotification = notification.object as? CENotification else { return }

        // Just remove from active notifications without triggering global state changes
        withAnimation(.easeOut(duration: 0.2)) {
            activeNotifications.removeAll(where: { $0.id == ceNotification.id })

            // If this was the last notification and they were manually shown, hide the panel
            if activeNotifications.isEmpty && isManuallyShown {
                isManuallyShown = false
            }
        }
    }
}
