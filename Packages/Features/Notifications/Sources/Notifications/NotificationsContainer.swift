//
//  NotificationsContainer.swift
//  Notifications
//
//  Created by Matthijs Eikelenboom on 05/07/2026.
//

import Factory

public extension Container {
    /// The app-wide notification manager. Owned by the Notifications package so the
    /// package's own view models can `@LazyInjected` it; the default is the real
    /// `NotificationManager` singleton.
    var notificationManager: Factory<NotificationManaging> {
        self { @MainActor in NotificationManager() as NotificationManaging }.singleton
    }
}
