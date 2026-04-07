//
//  NotificationPanelViewModel.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/14/24.
//

import SwiftUI

/// Coordinates notification display, auto-hide timers, panel visibility, and toolbar integration.
///
/// Methods are organized across focused extensions:
/// - `+TimerManagement`: auto-hide scheduling, pause/resume
/// - `+Visibility`: panel show/hide, focus handling
/// - `+NotificationHandling`: insertion, dismissal, event handling
/// - `+Toolbar`: dynamic toolbar item management
final class NotificationPanelViewModel: ObservableObject {
    /// Currently displayed notifications in the panel
    @Published internal(set) var activeNotifications: [CENotification] = []

    /// Whether notifications panel was manually shown via toolbar
    @Published internal(set) var isPresented: Bool = false

    /// Set of hidden notification IDs
    @Published internal(set) var hiddenNotificationIds: Set<UUID> = []

    @Published var scrolledToTop: Bool = true

    /// Timers for notifications
    var timers: [UUID: Timer] = [:]

    /// Display duration for notifications
    let displayDuration: TimeInterval = 5.0

    /// Whether notifications are paused
    var isPaused: Bool = false

    var notificationManager = NotificationManager.shared

    /// A filtered list of active notifications.
    var visibleNotifications: [CENotification] {
        activeNotifications.filter { !hiddenNotificationIds.contains($0.id) }
    }

    weak var windowController: NSWindowController?

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
}
