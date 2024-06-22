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
                    Text(selected.title)
                        .font(.headline)

                    Text(selected.id)
                        .foregroundStyle(.secondary)
                        .font(.system(size: 8))

                    Divider()
                        .padding(.vertical, 5)

                    if let message = selected.message, !message.isEmpty {
                        Text(message)
                            .fixedSize(horizontal: false, vertical: true)
                            .transition(.identity)
                    } else {
                        Text("No Details")
                    }

                    if selected.isLoading {
                        if let percentage = selected.percentage {
                            ProgressView(value: percentage) {
                                // Text("Progress")
                            } currentValueLabel: {
                                Text("\(String(format: "%.0f", percentage * 100))%")
                            }.padding(.top, 5)
                        } else {
                            ProgressView()
                                .progressViewStyle(.linear)
                                .padding(.top, 5)
                        }
                    }

                    Spacer()
                    Divider()

                    HStack {
                        Button(action: {
                            withAnimation {
                                selectedTaskNotificationIndex -= 1
                            }
                        }, label: {
                            Image(systemName: "chevron.left")
                        })
                        .disabled(
                            selectedTaskNotificationIndex - 1 < 0
                        )

                        Spacer()

                        Text("\(selectedTaskNotificationIndex + 1)")

                        Spacer()

                        Button(action: {
                            withAnimation {
                                selectedTaskNotificationIndex += 1
                            }
                        }, label: {
                            Image(systemName: "chevron.right")
                        })
                        .disabled(
                            selectedTaskNotificationIndex + 1 == taskNotificationHandler.notifications.count
                        )
                    }.animation(.spring, value: selected)
                } else {
                    Text("Task done")
                        .font(.headline)

                    Divider()
                        .padding(.vertical, 5)

                    Text("The task has been deleted and is no longer available.")
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.identity)
                }
            }
        }
        .padding(5)
        .frame(width: 220)
        .onChange(of: taskNotificationHandler.notifications) { newValue in
            if selectedTaskNotificationIndex >= newValue.count {
                selectedTaskNotificationIndex = 0
            }
        }
    }
}

#Preview {
    TaskNotificationsDetailView(taskNotificationHandler: TaskNotificationHandler())
}
