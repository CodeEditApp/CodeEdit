//
//  TaskSidebarTileView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 27.06.24.
//

import SwiftUI

struct TaskSidebarTileView: View {
    @ObservedObject var activeTask: CEActiveTask
    var body: some View {
        HStack {
            Image(systemName: "gearshape")
                .imageScale(.medium)
            Text(activeTask.task.name)

            Spacer()

            Circle()
                .fill(activeTask.status.color)
                .frame(width: 5, height: 5)
        }
    }
}
