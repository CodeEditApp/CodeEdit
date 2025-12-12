//
//  NotificationPanelView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/10/24.
//

import SwiftUI

struct NotificationPanelView: View {
    @EnvironmentObject private var workspace: WorkspaceDocument
    @Environment(\.controlActiveState)
    private var controlActiveState

    @ObservedObject private var notificationManager = NotificationManager.shared
    @FocusState private var isFocused: Bool

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

    @ViewBuilder var notifications: some View {
        let visibleNotifications = workspace.notificationPanel.activeNotifications.filter {
            workspace.notificationPanel.isNotificationVisible($0)
        }

        VStack(spacing: 8) {
            ForEach(visibleNotifications, id: \.id) { notification in
                NotificationBannerView(
                    notification: notification,
                    onDismiss: {
                        workspace.notificationPanel.dismissNotification(notification)
                    },
                    onAction: {
                        notification.action()
                        if workspace.notificationPanel.isPresented {
                            workspace.notificationPanel.toggleNotificationsVisibility()
                            workspace.notificationPanel.dismissNotification(notification, disableAnimation: true)
                        } else {
                            workspace.notificationPanel.dismissNotification(notification)
                        }
                    }
                )
            }
        }
        .padding(10)
        .animation(.easeInOut(duration: 0.3), value: visibleNotifications)
    }

    @ViewBuilder var notificationsWithScrollView: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .trailing, spacing: 0) {
                            Color.clear
                                .frame(height: 0)
                                .id(topID)
                                .background(
                                    GeometryReader {
                                        Color.clear.preference(
                                            key: ViewOffsetKey.self,
                                            value: -$0.frame(in: .named("scroll")).origin.y
                                        )
                                    }
                                )
                                .onPreferenceChange(ViewOffsetKey.self) {
                                    if $0 <= 0.0 && !workspace.notificationPanel.scrolledToTop {
                                        workspace.notificationPanel.scrolledToTop = true
                                    } else if $0 > 0.0 && workspace.notificationPanel.scrolledToTop {
                                        workspace.notificationPanel.scrolledToTop = false
                                    }
                                }
                            notifications
                        }
                        .background(
                            GeometryReader { proxy in
                                Color.clear.onChange(of: proxy.size.height) { _, newValue in
                                    contentHeight = newValue
                                    updateOverflow(contentHeight: newValue, containerHeight: geometry.size.height)
                                }
                            }
                        )
                    }
                    .frame(maxWidth: notificationWidth, alignment: .trailing)
                    .frame(height: min(geometry.size.height, contentHeight))
                    .scrollDisabled(!hasOverflow)
                    .coordinateSpace(name: "scroll")
                    .onChange(of: isFocused) { _, newValue in
                        workspace.notificationPanel.handleFocusChange(isFocused: newValue)
                    }
                    .onChange(of: geometry.size.height) { _, newValue in
                        updateOverflow(contentHeight: contentHeight, containerHeight: newValue)
                    }
                    .onChange(of: workspace.notificationPanel.isPresented) { _, isPresented in
                        if !isPresented && !workspace.notificationPanel.scrolledToTop {
                            // If scrolled, delay scroll animation until after notifications are hidden
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    proxy.scrollTo(topID, anchor: .top)
                                }
                            }
                        }
                    }
                    .allowsHitTesting(
                        workspace.notificationPanel.activeNotifications
                            .contains { workspace.notificationPanel.isNotificationVisible($0) }
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
                    .focusable()
                    .focusEffectDisabled()
                    .focused($isFocused)
                    .onChange(of: workspace.notificationPanel.isPresented) { _, isPresented in
                        if isPresented {
                            isFocused = true
                        }
                    }
                    .onChange(of: controlActiveState) { _, newState in
                        if newState != .active && newState != .key && workspace.notificationPanel.isPresented {
                            // Delay hiding notifications to match animation timing
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                workspace.notificationPanel.toggleNotificationsVisibility()
                            }
                        }
                    }
            } else {
                notificationsWithScrollView
            }
        }
        .opacity(controlActiveState == .active || controlActiveState == .key ? 1 : 0)
        .offset(
            x: (controlActiveState == .active || controlActiveState == .key) &&
                (workspace.notificationPanel.isPresented || workspace.notificationPanel.scrolledToTop)
                ? 0
                : 350
        )
        .animation(.easeInOut(duration: 0.3), value: workspace.notificationPanel.isPresented)
        .animation(.easeInOut(duration: 0.3), value: workspace.notificationPanel.scrolledToTop)
        .animation(.easeInOut(duration: 0.2), value: controlActiveState)
    }
}
