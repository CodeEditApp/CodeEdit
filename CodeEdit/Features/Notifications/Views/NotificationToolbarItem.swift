//
//  NotificationToolbarItem.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/10/24.
//

import SwiftUI

struct NotificationToolbarItem: View {
    @ObservedObject private var notificationManager = NotificationManager.shared
    @Environment(\.controlActiveState)
    private var controlActiveState
    @State private var showingPopover = false

    var body: some View {
        if notificationManager.unreadCount > 0 {
            Button {
                // Hide all notifications from overlay
                notificationManager.hideOverlayNotifications()
                showingPopover.toggle()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "bell.badge.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(controlActiveState == .inactive ? .secondary : Color.accentColor, .primary)
                    Text("\(notificationManager.unreadCount)")
                        .monospacedDigit()
                }
            }
            .popover(isPresented: $showingPopover, arrowEdge: .bottom) {
                NotificationListView()
            }
            .onChange(of: showingPopover) { isShowing in
                if !isShowing {
                    // Restore only sticky notifications when popover closes
                    notificationManager.restoreOverlayStickies()
                }
            }
            .transition(.opacity.animation(.none))
        }
    }
}
