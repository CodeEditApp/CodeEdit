//
//  TaskNotificationView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 21.06.24.
//

import SwiftUI

struct TaskNotificationView: View {
    @Environment(\.controlActiveState)
    private var activeState

    @ObservedObject var taskNotificationHandler: TaskNotificationHandler
    @State private var isPresented: Bool = false
    @State var notification: TaskNotificationModel?

    var body: some View {
        ZStack {
            if let notification {
                HStack {
                    Text(notification.title)
                        .font(.subheadline)
                        .transition(
                            .asymmetric(insertion: .move(edge: .top), removal: .move(edge: .bottom))
                            .combined(with: .opacity)
                        )
                        .id("NotificationTitle" + notification.title)

                    if notification.isLoading {
                        CECircularProgressView(
                            progress: notification.percentage,
                            currentTaskCount: taskNotificationHandler.notifications.count
                        )
                        .padding(.horizontal, -1)
                        .frame(height: 16)
                    } else {
                        if taskNotificationHandler.notifications.count > 1 {
                            Text("\(taskNotificationHandler.notifications.count)")
                                .font(.caption)
                                .padding(5)
                                .background(
                                    Circle()
                                        .foregroundStyle(.gray)
                                        .opacity(0.2)
                                )
                                .padding(-5)
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
                .opacity(activeState == .inactive ? 0.4 : 1.0)
                .padding(3)
                .padding(-3)
                .padding(.trailing, 3)
                .popover(isPresented: $isPresented, arrowEdge: .bottom) {
                    TaskNotificationsDetailView(taskNotificationHandler: taskNotificationHandler)
                }
                .onTapGesture {
                    self.isPresented.toggle()
                }
            }
        }
        .animation(.easeInOut, value: notification)
        .onChange(of: taskNotificationHandler.notifications) { newValue in
            withAnimation {
                notification = newValue.first
            }
        }
    }

}

#Preview {
    TaskNotificationView(taskNotificationHandler: TaskNotificationHandler())
}
