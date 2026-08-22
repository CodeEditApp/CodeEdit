//
//  NotificationPanelViewModel.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/14/24.
//

import SwiftUI
import Combine
import CodeEditCore

/// Coordinates notification display, auto-hide timers, panel visibility, and toolbar integration.
///
/// Methods are organized across focused extensions:
/// - `+TimerManagement`: auto-hide scheduling, pause/resume
/// - `+Visibility`: panel show/hide, focus handling
/// - `+NotificationHandling`: insertion, dismissal, event handling
/// - `+Toolbar`: dynamic toolbar item management
@MainActor
public final class NotificationPanelViewModel: ObservableObject {
    /// Currently displayed notifications in the panel
    @Published var activeNotifications: [CENotification] = []

    /// Whether notifications panel was manually shown via toolbar
    @Published var isPresented: Bool = false

    /// Set of hidden notification IDs
    @Published var hiddenNotificationIds: Set<UUID> = []

    @Published var scrolledToTop: Bool = true

    /// Number of unread notifications, republished from the notification manager for view observation.
    @Published private(set) var unreadCount: Int = 0

    /// Timers for notifications
    var timers: [UUID: Timer] = [:]

    /// Display duration for notifications
    let displayDuration: TimeInterval = 5.0

    /// Whether notifications are paused
    var isPaused: Bool = false

    /// Non-private so the app shell's toolbar extension can read `unreadCount` through it.
    public let notificationManager: NotificationManaging

    let eventBus: EventBus

    private var cancellables = Set<AnyCancellable>()

    /// A filtered list of active notifications.
    public var visibleNotifications: [CENotification] {
        activeNotifications.filter { !hiddenNotificationIds.contains($0.id) }
    }

    public weak var windowController: NSWindowController?

    /// Hook set by the app shell to refresh the window toolbar's notification item when
    /// notification state changes. Toolbar mutation is app-shell responsibility (it uses
    /// app-defined `NSToolbarItem.Identifier`s), so the package only signals; the app acts.
    public var onToolbarUpdateRequested: (() -> Void)?

    public init(notificationManager: NotificationManaging, eventBus: EventBus) {
        self.notificationManager = notificationManager
        self.eventBus = eventBus

        // Observe notification additions and dismissals
        eventBus.subscribe(CENotificationEvent.self)
            .receive(on: RunLoop.main)
            .sink { [weak self] event in self?.handle(event) }
            .store(in: &cancellables)

        // Republish the unread count for views (the manager is behind a protocol and not observable).
        notificationManager.notificationsPublisher
            .map { notifications in notifications.filter { !$0.isRead }.count }
            .receive(on: RunLoop.main)
            .assign(to: &$unreadCount)

        // Load initial notifications from NotificationManager
        notificationManager.notifications.forEach { notification in
            handleNewNotification(notification)
        }
    }
}
