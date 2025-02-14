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

    @State private var hasOverflow: Bool = false
    @State private var contentHeight: CGFloat = 0.0

    private func updateOverflow(contentHeight: CGFloat, containerHeight: CGFloat) {
        if !hasOverflow && contentHeight > containerHeight {
            hasOverflow = true
        } else if hasOverflow && contentHeight <= containerHeight {
            hasOverflow = false
        }
    }

    var notifications: some View {
        VStack(spacing: 8) {
            ForEach(
                notificationManager.activeNotifications.filter {
                    notificationManager.isNotificationVisible($0)
                },
                id: \.id
            ) { notification in
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
            }
        }
        .padding(10)
    }

    var notificationsWithScrollView: some View {
        GeometryReader { geometry in
            HStack {
                Spacer() // Push content to trailing edge
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .trailing, spacing: 0) {
                            // Invisible anchor view at the top to scroll back to when closed
                            Color.clear.frame(height: 0).id(topID)
                            notifications
                        }
                        .background(
                            GeometryReader { proxy in
                                Color.clear.onChange(of: proxy.size.height) { newValue in
                                    contentHeight = newValue
                                    updateOverflow(contentHeight: newValue, containerHeight: geometry.size.height)
                                }
                            }
                        )
                    }
                    .frame(maxWidth: notificationWidth, alignment: .trailing)
                    .frame(height: min(geometry.size.height, contentHeight))
                    .scrollDisabled(!hasOverflow)
                    .onChange(of: geometry.size.height) { newValue in
                        updateOverflow(contentHeight: contentHeight, containerHeight: newValue)
                    }
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
                    .allowsHitTesting(
                        notificationManager.activeNotifications
                            .contains { notificationManager.isNotificationVisible($0) }
                    )
                }
            }
        }
    }

    var body: some View {
        Group {
            if #available(macOS 14.0, *) {
                notificationsWithScrollView
                    .scrollClipDisabled(true)
            } else {
                notificationsWithScrollView
            }
        }
        .opacity(controlActiveState == .active || controlActiveState == .key ? 1 : 0)
        .offset(x: controlActiveState == .active || controlActiveState == .key ? 0 : 350)
        .animation(.easeInOut(duration: 0.2), value: controlActiveState)
    }
}
