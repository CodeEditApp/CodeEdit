//
//  TaskNotificationView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 21.06.24.
//

import SwiftUI

struct TaskNotificationView: View {
    @ObservedObject var taskNotificationHandler: TaskNotificationHandler
    @State private var hovered: Bool = false
    @State private var isPresented: Bool = false

    var body: some View {
        if let notification = taskNotificationHandler.notifications.first {
            HStack {
                Text(notification.title)
                    .font(.subheadline)

                if notification.isLoading {
                    CustomLoadingRingView(
                        progress: notification.percentage,
                        currentTaskCount: taskNotificationHandler.notifications.count
                    )
                    .frame(height: 15)
                    .popover(isPresented: $isPresented) {
                        TaskNotificationsDetailView(taskNotificationHandler: taskNotificationHandler)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.isPresented.toggle()
                    }
                } else {
                    if taskNotificationHandler.notifications.count > 1 {
                        Text("\(taskNotificationHandler.notifications.count)")
                            .background(
                                Circle()
                                    .foregroundStyle(.gray)
                            )
                    }
                }
            }
            .animation(.easeInOut, value: notification)
            .padding(3)
            .onHover { isHovered in
                self.hovered = isHovered
            }
            .padding(-3)
        }
    }
}
