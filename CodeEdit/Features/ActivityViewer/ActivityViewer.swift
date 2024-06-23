//
//  ActivityViewer.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 21.06.24.
//

import SwiftUI

/// A view that shows the activity bar and the current status of any executed task
struct ActivityViewer: View {
    @Environment(\.colorScheme)
    var colorScheme

    @ObservedObject var taskNotificationHandler: TaskNotificationHandler

    var body: some View {
        HStack(spacing: 0) {
            // This is only a placeholder for the task popover(coming in the next pr)
            Rectangle()
                .frame(height: 22)
                .hidden()
                .fixedSize()

            Spacer(minLength: 0)

            TaskNotificationView(taskNotificationHandler: taskNotificationHandler)
                .fixedSize()
        }
        .fixedSize(horizontal: false, vertical: false)
        .padding(.horizontal, 10)
        .background {
            if colorScheme == .dark {
                RoundedRectangle(cornerRadius: 5)
                    .opacity(0.10)
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .opacity(0.1)
            }
        }
    }
}
