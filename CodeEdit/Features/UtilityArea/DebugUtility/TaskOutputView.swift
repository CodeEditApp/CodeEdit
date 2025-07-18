//
//  TaskOutputView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 27.06.24.
//

import SwiftUI

struct TaskOutputView: View {
    @ObservedObject var activeTask: CEActiveTask

    var body: some View {
        if activeTask.output != nil, let workspaceURL = activeTask.workspaceURL {
            TerminalEmulatorView(url: workspaceURL, task: activeTask)
        } else {
            EmptyView()
        }
    }
}
