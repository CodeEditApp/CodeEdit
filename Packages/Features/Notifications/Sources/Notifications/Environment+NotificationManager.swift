//
//  Environment+NotificationManager.swift
//  Notifications
//
//  Created by Matthijs Eikelenboom on 10/07/2026.
//

import SwiftUI

private struct NotificationManagerKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: NotificationManaging? = nil
}

extension EnvironmentValues {
    /// The app-wide notification manager. Optional because notification UI rendered
    /// outside a configured app context (previews, tests) has no manager; consumers
    /// no-op via optional chaining. Injected by the app shell.
    public var notificationManager: NotificationManaging? {
        get { self[NotificationManagerKey.self] }
        set { self[NotificationManagerKey.self] = newValue }
    }
}
