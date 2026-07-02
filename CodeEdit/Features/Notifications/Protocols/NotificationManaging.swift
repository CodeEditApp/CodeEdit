//
//  NotificationManaging.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 11/04/26.
//

import SwiftUI
import Combine

/// Protocol for managing application notifications.
protocol NotificationManaging: AnyObject {
    /// Collection of all notifications, both read and unread.
    var notifications: [CENotification] { get }

    /// Fires on any change to ``notifications``, including `isRead` mutations. Replays the current value.
    var notificationsPublisher: AnyPublisher<[CENotification], Never> { get }

    /// Posts a new notification.
    func post(_ notification: CENotification)

    func dismissNotification(_ notification: CENotification)
    func markAsRead(_ notification: CENotification)
}

extension NotificationManaging {
    /// Number of unread notifications.
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    /// Posts a new notification
    /// - Parameters:
    ///   - iconSymbol: SF Symbol or CodeEditSymbol name for the notification icon
    ///   - iconColor: Color for the icon
    ///   - title: Main notification title
    ///   - description: Detailed notification message
    ///   - actionButtonTitle: Title for the action button
    ///   - action: Closure to execute when action button is clicked
    ///   - isSticky: Whether the notification should persist until manually dismissed
    func post(
        iconSymbol: String,
        iconColor: Color? = Color(.systemBlue),
        title: String,
        description: String,
        actionButtonTitle: String,
        action: @escaping () -> Void,
        isSticky: Bool = false
    ) {
        post(CENotification(
            iconSymbol: iconSymbol,
            iconColor: iconColor,
            title: title,
            description: description,
            actionButtonTitle: actionButtonTitle,
            action: action,
            isSticky: isSticky,
            isRead: false
        ))
    }

    /// Posts a new notification
    /// - Parameters:
    ///   - iconImage: Image for the notification icon
    ///   - title: Main notification title
    ///   - description: Detailed notification message
    ///   - actionButtonTitle: Title for the action button
    ///   - action: Closure to execute when action button is clicked
    ///   - isSticky: Whether the notification should persist until manually dismissed
    func post(
        iconImage: Image,
        title: String,
        description: String,
        actionButtonTitle: String,
        action: @escaping () -> Void,
        isSticky: Bool = false
    ) {
        post(CENotification(
            iconImage: iconImage,
            title: title,
            description: description,
            actionButtonTitle: actionButtonTitle,
            action: action,
            isSticky: isSticky
        ))
    }

    /// Posts a new notification
    /// - Parameters:
    ///   - iconText: Text or emoji for the notification icon
    ///   - iconTextColor: Color of the text/emoji (defaults to primary label color)
    ///   - iconColor: Background color for the icon
    ///   - title: Main notification title
    ///   - description: Detailed notification message
    ///   - actionButtonTitle: Title for the action button
    ///   - action: Closure to execute when action button is clicked
    ///   - isSticky: Whether the notification should persist until manually dismissed
    func post(
        iconText: String,
        iconTextColor: Color? = nil,
        iconColor: Color? = Color(.systemBlue),
        title: String,
        description: String,
        actionButtonTitle: String,
        action: @escaping () -> Void,
        isSticky: Bool = false
    ) {
        post(CENotification(
            iconText: iconText,
            iconTextColor: iconTextColor,
            iconColor: iconColor,
            title: title,
            description: description,
            actionButtonTitle: actionButtonTitle,
            action: action,
            isSticky: isSticky
        ))
    }
}
