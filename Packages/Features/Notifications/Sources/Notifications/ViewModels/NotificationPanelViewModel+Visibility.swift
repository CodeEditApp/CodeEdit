//
//  NotificationPanelViewModel+Visibility.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/14/24.
//

import SwiftUI

/// Panel visibility control, focus handling, and show/hide transitions.
extension NotificationPanelViewModel {
    /// Whether a notification should be visible in the panel
    func isNotificationVisible(_ notification: CENotification) -> Bool {
        if notification.isBeingDismissed {
            return true // Always show notifications being dismissed
        }
        if notification.isSticky {
            return true // Always show sticky notifications
        }
        if isPresented {
            return true // Show all notifications when manually shown
        }
        return !hiddenNotificationIds.contains(notification.id)
    }

    /// Handles focus changes for the notification panel
    func handleFocusChange(isFocused: Bool) {
        if !isFocused {
            // Only hide if manually shown and focus is completely lost
            if isPresented {
                toggleNotificationsVisibility()
            }
        }
    }

    /// Toggles visibility of notifications in the panel
    func toggleNotificationsVisibility() {
        if isPresented {
            if !scrolledToTop {
                // Just set isPresented to false to trigger the offset animation
                withAnimation(.easeInOut(duration: 0.3)) {
                    isPresented = false
                }

                // After the slide-out animation, hide notifications
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    MainActor.assumeIsolated {
                        guard let self else { return }
                        // Hide non-sticky notifications
                        self.activeNotifications
                            .filter { !$0.isSticky }
                            .forEach { self.hiddenNotificationIds.insert($0.id) }
                        self.objectWillChange.send()

                        // After notifications are hidden, reset scroll position
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                            MainActor.assumeIsolated {
                                self?.scrolledToTop = true
                            }
                        }
                    }
                }
            } else {
                // At top, just hide normally
                hideNotifications()
            }
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                isPresented = true
                hiddenNotificationIds.removeAll()
                objectWillChange.send()
            }
        }
    }

    func hideNotifications() {
        withAnimation(.easeInOut(duration: 0.3)) {
            self.isPresented = false
            self.activeNotifications
                .filter { !$0.isSticky }
                .forEach { self.hiddenNotificationIds.insert($0.id) }
            self.objectWillChange.send()
        }
    }
}
