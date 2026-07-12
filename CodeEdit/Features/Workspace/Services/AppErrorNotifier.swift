//
//  AppErrorNotifier.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 12/07/2026.
//

import CodeEditCore
import CENotifications

/// App-shell binding of the `ErrorNotifying` seam onto the notification system.
final class AppErrorNotifier: ErrorNotifying {
    private let notificationManager: NotificationManaging

    init(notificationManager: NotificationManaging) {
        self.notificationManager = notificationManager
    }

    @MainActor
    func postError(title: String, description: String) {
        notificationManager.post(
            iconSymbol: "xmark.circle",
            iconColor: .clear,
            title: title,
            description: description,
            actionButtonTitle: "Done",
            action: {}
        )
    }
}
