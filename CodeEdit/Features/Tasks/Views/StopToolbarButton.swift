//
//  StopToolbarButton.swift
//  CodeEdit
//
//  Created by Austin Condiff on 8/3/24.
//

import SwiftUI
import Combine

struct StopToolbarButton: View {
    // TODO: try to get this from the environment
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
        .onChange(of: taskManager.selectedTaskID) { _ in updateStatusListener() }
        .onChange(of: taskManager.activeTasks) { _ in updateStatusListener() }
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

struct StartTaskToolbarButton: View {
    @UpdatingWindowController var windowController: CodeEditWindowController?

    // TODO: try to get this from the environment
    @ObservedObject var taskManager: TaskManager
    @EnvironmentObject var workspace: WorkspaceDocument

    var utilityAreaCollapsed: Bool {
        windowController?.workspace?.utilityAreaModel?.isCollapsed ?? true
    }

    var body: some View {
        Button {
            self.runActiveTask()
            if utilityAreaCollapsed {
                CommandManager.shared.executeCommand("open.drawer")
            }
            workspace.utilityAreaModel?.selectedTab = .debugConsole
            taskManager.taskShowingOutput = taskManager.selectedTaskID
        } label: {
            Label("Start", systemImage: "play.fill")
                .labelStyle(.iconOnly)
                .font(.system(size: 18, weight: .regular))
                .help("Start selected task")
                .frame(width: 28)
                .offset(CGSize(width: 0, height: 2.5))
        }
    }

    private func runActiveTask() {
        taskManager.executeActiveTask()
    }
}
