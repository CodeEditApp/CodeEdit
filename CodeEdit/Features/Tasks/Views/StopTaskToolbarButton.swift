//
//  StopTaskToolbarButton.swift
//  CodeEdit
//
//  Created by Austin Condiff on 8/3/24.
//

import SwiftUI
import Combine

struct StopTaskToolbarButton: View {
    @Environment(\.controlActiveState)
    private var activeState

    @ObservedObject var taskManager: TaskManager

    /// Tracks the current selected task's status. Updated by `updateStatusListener`
    @State private var currentSelectedStatus: CETaskStatus?
    /// The listener that listens to the active task's status publisher. Is updated frequently as the active task
    /// changes.
    @State private var statusListener: AnyCancellable?

    var body: some View {
        HStack {
            if let currentSelectedStatus, currentSelectedStatus == .running {
                    Button {
                        taskManager.terminateActiveTask()
                    } label: {
                        Label("Stop", systemImage: "stop.fill")
                            .labelStyle(.iconOnly)
                            .opacity(activeState == .inactive ? 0.5 : 1.0)
                            .font(.system(size: 15, weight: .regular))
                            .help("Stop selected task")
                            .frame(width: 28)
                            .offset(y: 1.5)
                    }
                    .frame(height: 22)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .frame(width: 38, height: 22)
        .animation(
            .easeInOut(duration: 0.3),
            value: currentSelectedStatus
        )
        .onChange(of: taskManager.selectedTaskID) { _, _ in updateStatusListener() }
        .onChange(of: taskManager.activeTasks) { _, _ in updateStatusListener() }
        .onAppear(perform: updateStatusListener)
        .onDisappear {
            statusListener?.cancel()
        }
    }

    /// Update the ``statusListener`` to listen to a potentially new active task.
    private func updateStatusListener() {
        statusListener?.cancel()
        currentSelectedStatus = taskManager.activeTasks[taskManager.selectedTaskID ?? UUID()]?.status
        guard let id = taskManager.selectedTaskID else { return }
        statusListener = taskManager.activeTasks[id]?.$status.sink { newValue in
            currentSelectedStatus = newValue
        }
    }
}
