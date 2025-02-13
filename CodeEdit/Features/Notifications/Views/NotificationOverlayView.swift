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

    // ID for the top anchor
    private let topID = "top"

    // Fixed width for notifications
    private let notificationWidth: CGFloat = 320 // 300 + 10 padding on each side

    var notifications: some View {
        VStack(spacing: 8) {
            ForEach(notificationManager.activeNotifications, id: \.id) { notification in
                if controlActiveState == .active || controlActiveState == .key {
                    NotificationBannerView(
                        notification: notification,
                        onDismiss: {
                            notificationManager.dismissNotification(notification)
                        },
                        onAction: {
                            notification.action()
                            notificationManager.dismissNotification(notification)
                            // Only hide if manually shown
                            if notificationManager.isManuallyShown {
                                notificationManager.toggleNotificationsVisibility()
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .opacity
                    ))
                }
            }
        }
        .padding(10)
    }

    var body: some View {
        ViewThatFits(in: .vertical) {
            notifications
                .border(.red)
            GeometryReader { geometry in
                HStack {
                    Spacer() // Push content to trailing edge
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 0) {
                                // Invisible anchor view at the top to scroll back to when closed
                                Color.clear.frame(height: 0).id(topID)
                                notifications
                            }
                            .padding(.bottom, 30) // Account for the status bar
                        }
                        .frame(width: notificationWidth)
                        .frame(maxHeight: geometry.size.height)
                        .scrollDisabled(!notificationManager.isManuallyShown)
                        .onChange(of: notificationManager.isManuallyShown) { isShown in
                            if !isShown {
                                // Delay scroll animation until after notifications are hidden
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        proxy.scrollTo(topID, anchor: .top)
                                    }
                                }
                            }
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: notificationManager.activeNotifications)
            }
        }
    }
}
