//
//  NotificationOverlayView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/10/24.
//

import SwiftUI

struct NotificationOverlayView: View {
    @Environment(\.controlActiveState)
    private var controlActiveState

    @ObservedObject private var notificationManager = NotificationManager.shared

    @Namespace private var animation

    var body: some View {
        VStack(spacing: 10) {
            ForEach(notificationManager.activeNotifications, id: \.id) { notification in
                if controlActiveState == .active || controlActiveState == .key {
                    NotificationBannerView(
                        notification: notification,
                        namespace: animation,
                        onDismiss: {
                            notificationManager.dismissNotification(notification)
                        },
                        onAction: {
                            notification.action()
                            notificationManager.dismissNotification(notification)
                        }
                    )
                    .environment(\.isOverlay, true)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        )
                    )
                }
            }
        }
        .padding(8)
        .animation(.easeInOut(duration: 0.2), value: notificationManager.activeNotifications)
    }
}
