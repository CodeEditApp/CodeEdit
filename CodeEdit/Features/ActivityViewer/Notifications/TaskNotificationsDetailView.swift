//
//  TaskNotificationsDetailView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 21.06.24.
//

import SwiftUI

struct TaskNotificationsDetailView: View {
    @ObservedObject var taskNotificationHandler: TaskNotificationHandler
    @State private var selectedTaskNotificationIndex: Int = 0
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                ForEach(taskNotificationHandler.notifications, id: \.id) { notification in
                    HStack(alignment: .center, spacing: 8) {
                        CECircularProgressView(progress: notification.percentage)
                            .frame(width: 16, height: 16)
                        VStack(alignment: .leading) {
                            Text(notification.title)
                                .fixedSize(horizontal: false, vertical: true)
                                .transition(.identity)

                            if let message = notification.message, !message.isEmpty {
                                Text(message)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding(15)
        .frame(minWidth: 320)
        .onChange(of: taskNotificationHandler.notifications) { _, newValue in
            if selectedTaskNotificationIndex >= newValue.count {
                selectedTaskNotificationIndex = 0
            }
        }
    }
}

#Preview {
    TaskNotificationsDetailView(taskNotificationHandler: TaskNotificationHandler())
}
