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
            VStack(alignment: .leading) {
                if let selected =
                    taskNotificationHandler
                    .notifications[safe: selectedTaskNotificationIndex] {

                    HStack {
                        if selected.isLoading {
                            CustomLoadingRingView(
                                progress: selected.percentage,
                                currentTaskCount: taskNotificationHandler.notifications.count
                            )
                            .frame(height: 16)
                        }

                        VStack(alignment: .leading) {
                            Text(selected.title)
                            if let message = selected.message, !message.isEmpty {
                                Text(message)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .transition(.identity)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
        .padding(5)
        .frame(width: 300)
        .onChange(of: taskNotificationHandler.notifications) { newValue in
            if selectedTaskNotificationIndex >= newValue.count {
                selectedTaskNotificationIndex = 0
            }
        }
    }
}
