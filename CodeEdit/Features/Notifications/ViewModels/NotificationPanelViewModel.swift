//
//  NotificationPanelViewModel.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/14/24.
//

import SwiftUI
import Combine
import Factory
import CodeEditCore

/// Coordinates notification display, auto-hide timers, panel visibility, and toolbar integration.
///
/// Methods are organized across focused extensions:
/// - `+TimerManagement`: auto-hide scheduling, pause/resume
/// - `+Visibility`: panel show/hide, focus handling
/// - `+NotificationHandling`: insertion, dismissal, event handling
/// - `+Toolbar`: dynamic toolbar item management
final class NotificationPanelViewModel: ObservableObject {
    /// Currently displayed notifications in the panel
    @Published var activeNotifications: [CENotification] = []

    /// Whether notifications panel was manually shown via toolbar
    @Published var isPresented: Bool = false

    /// Set of hidden notification IDs
    @Published var hiddenNotificationIds: Set<UUID> = []

    @Published var scrolledToTop: Bool = true

    /// Timers for notifications
    var timers: [UUID: Timer] = [:]

    /// Display duration for notifications
    let displayDuration: TimeInterval = 5.0

    /// Whether notifications are paused
    var isPaused: Bool = false

    var notificationManager = Container.shared.notificationManager()

    @LazyInjected(\.eventBus)
    var eventBus

    private var cancellables = Set<AnyCancellable>()

    /// A filtered list of active notifications.
    var visibleNotifications: [CENotification] {
        activeNotifications.filter { !hiddenNotificationIds.contains($0.id) }
    }

    weak var windowController: NSWindowController?

    init() {
        // Observe notification additions and dismissals
        eventBus.subscribe(CENotificationEvent.self)
            .receive(on: RunLoop.main)
            .sink { [weak self] event in self?.handle(event) }
            .store(in: &cancellables)

        // Load initial notifications from NotificationManager
        notificationManager.notifications.forEach { notification in
            handleNewNotification(notification)
        }
    }
}
