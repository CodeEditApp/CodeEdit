//
//  NotificationPanelViewModel+Toolbar.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/14/24.
//

import AppKit

/// Dynamic toolbar item management for the notification badge.
extension NotificationPanelViewModel {
    func updateToolbarItem() {
        if #available(macOS 15.0, *) {
            guard let windowController, let toolbar = windowController.window?.toolbar else {
                return
            }

            let shouldShow = !self.visibleNotifications.isEmpty || NotificationManager.shared.unreadCount > 0
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
