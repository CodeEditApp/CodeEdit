//
//  TaskView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 8/4/24.
//

import SwiftUI

/// `TaskView` represents a single active task and observes its state.
/// - Parameter task: The task to be displayed and observed.
/// - Parameter status: The status of the task to be displayed.
struct TaskView: View {
    @ObservedObject var task: CETask
    var status: CETaskStatus

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "gearshape")
            Text(task.name)
                .frame(minWidth: 0)
            Spacer(minLength: 0)
        }
        .padding(.trailing, 7.5)
        .overlay(alignment: .trailing) {
            Circle()
                .fill(status.color)
                .frame(width: 5, height: 5)
                .padding(.trailing, 2.5)
        }
        .accessibilityElement()
        .accessibilityLabel(task.name)
    }
}
