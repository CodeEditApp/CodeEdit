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
        HStack {
            HStack(spacing: 0) {
                // This is only a placeholder for the task popover(coming in the next pr)
                Rectangle()
                    .frame(height: 22)
                    .hidden()

                Spacer()

                TaskNotificationView(taskNotificationHandler: taskNotificationHandler)
            }
            .padding(.horizontal, 10)
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .opacity(0.1)
            }
            .frame(minWidth: 200, idealWidth: 680)
        }
        .frame(height: 22)
    }
}
