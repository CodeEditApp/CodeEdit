//
//  TaskNotificationView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 21.06.24.
//

import SwiftUI

struct TaskNotificationView: View {
    @ObservedObject var taskNotificationHandler: TaskNotificationHandler
    @State private var isPresented: Bool = false

    var body: some View {
        if let notification = taskNotificationHandler.notifications.first {
            HStack {
                Text(notification.title)
                    .font(.subheadline)

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
            .animation(.easeInOut, value: notification)
            .padding(3)
            .padding(-3)
            .padding(.trailing, 3)
            .popover(isPresented: $isPresented, arrowEdge: .bottom) {
                TaskNotificationsDetailView(taskNotificationHandler: taskNotificationHandler)
            }.onTapGesture {
                self.isPresented.toggle()
            }
        }
    }
}

#Preview {
    TaskNotificationView(taskNotificationHandler: TaskNotificationHandler())
}
