//
//  NotificationPanelViewModel+Toolbar.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/14/24.
//

import AppKit
import Notifications

/// App-shell integration for the notification toolbar badge.
///
/// Window-toolbar mutation is app-shell responsibility (it uses the app-defined
/// `.notificationItem` / `.activityViewer` identifiers), so this lives in the app
/// target rather than the `Notifications` package. The package signals a refresh via
/// ``NotificationPanelViewModel/onToolbarUpdateRequested``, wired up in `WorkspaceWindowManager`.
extension NotificationPanelViewModel {
    func updateToolbarItem() {
        if #available(macOS 15.0, *) {
            guard let windowController, let toolbar = windowController.window?.toolbar else {
                return
            }

            let shouldShow = !visibleNotifications.isEmpty
                || notificationManager.unreadCount > 0
            if shouldShow && toolbar.items.filter({ $0.itemIdentifier == .notificationItem }).first == nil {
                guard let activityItemIdx = toolbar.items
                    .firstIndex(where: { $0.itemIdentifier == .activityViewer }) else {
                    return
                }
                toolbar.insertItem(withItemIdentifier: .space, at: activityItemIdx + 1)
                toolbar.insertItem(withItemIdentifier: .notificationItem, at: activityItemIdx + 2)
            }

            if !shouldShow, let index = toolbar.items
                .firstIndex(where: { $0.itemIdentifier == .notificationItem }) {
                toolbar.removeItem(at: index)
                toolbar.removeItem(at: index)
            }
        }
    }
}
