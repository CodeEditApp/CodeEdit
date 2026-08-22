//
//  CENotificationEvent.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom on 02/07/2026.
//

import Foundation

/// Describes a mutation of the in-app notification list.
///
/// Published by `NotificationManager`; consumed by `NotificationPanelViewModel`.
///
/// Carries only the notification id: the full `CENotification` model is UI-facing
/// (SwiftUI types and an action closure) and stays in the app target. Subscribers
/// resolve the model via `NotificationManager` when they need more than the id.
public struct CENotificationEvent: Event {
    public enum Action: Sendable {
        /// A notification was added to the list.
        case added(id: UUID)
        /// A notification was dismissed and removed from the list.
        case dismissed(id: UUID)
    }

    public let action: Action

    public init(_ action: Action) {
        self.action = action
    }
}
