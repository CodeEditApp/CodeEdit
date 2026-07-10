//
//  StartTaskToolbarButton.swift
//  CodeEdit
//
//  Created by Austin Condiff on 8/4/24.
//

import SwiftUI

struct StartTaskToolbarButton: View {
    @Environment(\.controlActiveState)
    private var activeState

    @Environment(\.commandManager)
    private var commandManager

    @ObservedObject var taskManager: TaskManager
    @EnvironmentObject var utilityAreaModel: UtilityAreaViewModel

    var utilityAreaCollapsed: Bool {
        utilityAreaModel.isCollapsed
    }

    var body: some View {
        Button {
            taskManager.executeActiveTask()
            if utilityAreaCollapsed {
                commandManager?.executeCommand("open.drawer")
            }
            utilityAreaModel.selectedTab = .debugConsole
            taskManager.taskShowingOutput = taskManager.selectedTaskID
        } label: {
            Label("Start", systemImage: "play.fill")
                .labelStyle(.iconOnly)
                .opacity(activeState == .inactive ? 0.5 : 1.0)
                .font(.system(size: 18, weight: .regular))
                .help("Start selected task")
                .frame(width: 28)
                .offset(CGSize(width: 0, height: 2.5))
        }
    }
}
