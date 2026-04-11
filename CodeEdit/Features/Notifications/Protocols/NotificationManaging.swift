//
//  NotificationManaging.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 11/04/26.
//

import SwiftUI

/// Protocol for managing application notifications.
protocol NotificationManaging: AnyObject, ObservableObject {
    var notifications: [CENotification] { get }
    var unreadCount: Int { get }

    func post(
        iconSymbol: String,
        iconColor: Color?,
        title: String,
        description: String,
        actionButtonTitle: String,
        action: @escaping () -> Void,
        isSticky: Bool
    )

    func post(
        iconImage: Image,
        title: String,
        description: String,
        actionButtonTitle: String,
        action: @escaping () -> Void,
        isSticky: Bool
    )

    func post(
        iconText: String,
        iconTextColor: Color?,
        iconColor: Color?,
        title: String,
        description: String,
        actionButtonTitle: String,
        action: @escaping () -> Void,
        isSticky: Bool
    )

    func dismissNotification(_ notification: CENotification)
    func markAsRead(_ notification: CENotification)
}
