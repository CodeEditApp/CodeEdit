import SwiftUI

struct NotificationToolbarItem: View {
    @ObservedObject private var notificationManager = NotificationManager.shared
    @Environment(\.controlActiveState)
    private var controlActiveState
    @State private var showingPopover = false

    var body: some View {
        if notificationManager.unreadCount > 0 {
            Button {
                if notificationManager.hasActiveNotification {
                    notificationManager.hideActiveNotification()
                }
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
            .transition(.opacity.animation(.none))
        }
    }
}
