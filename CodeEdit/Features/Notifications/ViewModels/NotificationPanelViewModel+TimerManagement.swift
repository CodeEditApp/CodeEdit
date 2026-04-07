//
//  NotificationPanelViewModel+TimerManagement.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/14/24.
//

import SwiftUI

/// Auto-hide timer scheduling, pausing, and resuming.
extension NotificationPanelViewModel {
    /// Starts the timer to automatically hide a notification
    func startHideTimer(for notification: CENotification) {
        guard !notification.isSticky && !isPresented else { return }

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
}
