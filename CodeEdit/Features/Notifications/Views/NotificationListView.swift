import SwiftUI

struct NotificationListView: View {
    @ObservedObject private var notificationManager = NotificationManager.shared
    @Namespace private var animation

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                if notificationManager.notifications.isEmpty {
                    Text("No notifications")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(notificationManager.notifications) { notification in
                        NotificationBannerView(
                            notification: notification,
                            namespace: animation,
                            onDismiss: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    notificationManager.dismissNotification(notification)
                                }
                            },
                            onAction: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    notification.action()
                                    notificationManager.dismissNotification(notification)
                                }
                            }
                        )
                        .environment(\.isOverlay, false)
                        .environment(\.isSingleListItem, notificationManager.notifications.count == 1)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }
                }
            }
            .padding(notificationManager.notifications.count == 1 ? 0 : 10)
            .animation(.easeInOut(duration: 0.2), value: notificationManager.notifications)
        }
    }
}
