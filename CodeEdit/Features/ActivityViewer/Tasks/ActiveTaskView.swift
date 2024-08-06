//
//  ActiveTaskView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 8/4/24.
//

import SwiftUI

// We need to observe each active task individually because:
// 1. Active tasks are nested inside TaskManager.
// 2. Reference types (like objects) do not notify observers when their internal state changes.
/// `ActiveTaskView` represents a single active task and observes its state.
/// - Parameter activeTask: The active task to be displayed and observed.
struct ActiveTaskView: View {
    @ObservedObject var activeTask: CEActiveTask

    var body: some View {
        TaskView(task: activeTask.task, status: activeTask.status)
    }
}
