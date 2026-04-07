//
//  NotificationPanelViewModel+NotificationHandling.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/14/24.
//

import SwiftUI

/// Notification insertion, dismissal, and event handling.
extension NotificationPanelViewModel {
    /// Inserts a notification in the correct position (sticky notifications on top)
    func insertNotification(_ notification: CENotification) {
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
        let operation = {
            self.insertNotification(notification)
            self.hiddenNotificationIds.remove(notification.id)
            if !self.isPresented && !notification.isSticky {
                self.startHideTimer(for: notification)
            }
        }

        if #available(macOS 26, *) {
            withAnimation(.easeInOut(duration: 0.3), operation) {
                self.updateToolbarItem()
            }
        } else {
            withAnimation(.easeInOut(duration: 0.3), operation)
        }
    }

    /// Dismisses a specific notification
    func dismissNotification(_ notification: CENotification, disableAnimation: Bool = false) {
        // Clean up timers
        timers[notification.id]?.invalidate()
        timers[notification.id] = nil
        hiddenNotificationIds.remove(notification.id)

        // Mark as being dismissed for animation
        if let index = activeNotifications.firstIndex(where: { $0.id == notification.id }) {
            if disableAnimation {
                self.activeNotifications.removeAll(where: { $0.id == notification.id })
                NotificationManager.shared.markAsRead(notification)
                NotificationManager.shared.dismissNotification(notification)
                return
            }

            var dismissingNotification = activeNotifications[index]
            dismissingNotification.isBeingDismissed = true
            activeNotifications[index] = dismissingNotification

            // Wait for fade animation before removing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                withAnimation(.easeOut(duration: 0.2)) {
                    self.activeNotifications.removeAll(where: { $0.id == notification.id })
                    if self.activeNotifications.isEmpty && self.isPresented {
                        self.isPresented = false
                    }
                }

                NotificationManager.shared.markAsRead(notification)
                NotificationManager.shared.dismissNotification(notification)
            }
        }
    }

    @objc
    func handleNewNotificationAdded(_ notification: Notification) {
        guard let ceNotification = notification.object as? CENotification else { return }
        handleNewNotification(ceNotification)
    }

    @objc
    func handleNotificationRemoved(_ notification: Notification) {
        guard let ceNotification = notification.object as? CENotification else { return }

        let operation: () -> Void = {
            self.activeNotifications.removeAll(where: { $0.id == ceNotification.id })

            // If this was the last notification and they were manually shown, hide the panel
            if self.activeNotifications.isEmpty && self.isPresented {
                self.isPresented = false
            }
        }

        // Just remove from active notifications without triggering global state changes
        if #available(macOS 26, *) {
            withAnimation(.easeOut(duration: 0.2), operation) {
                self.updateToolbarItem()
            }
        } else {
            withAnimation(.easeOut(duration: 0.2), operation)
        }
    }
}
