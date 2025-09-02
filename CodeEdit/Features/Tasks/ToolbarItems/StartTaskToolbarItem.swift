//
//  StartTaskToolbarItem.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/28/25.
//

import AppKit

@available(macOS 26, *)
final class StartTaskToolbarItem: NSToolbarItem {
    private weak var workspace: WorkspaceDocument?

    private var utilityAreaCollapsed: Bool {
        workspace?.utilityAreaModel?.isCollapsed ?? true
    }

    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
        super.init(itemIdentifier: NSToolbarItem.Identifier("StartTaskToolbarItem"))

        image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: nil)
        let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        image = image?.withSymbolConfiguration(config) ?? image

        paletteLabel = "Start Task"
        toolTip = "Run the selected task"
        target = self
        action = #selector(startTask)
        isBordered = true
    }

    @objc
    func startTask() {
        guard let taskManager = workspace?.taskManager else { return }

        taskManager.executeActiveTask()
        if utilityAreaCollapsed {
            CommandManager.shared.executeCommand("open.drawer")
        }
        workspace?.utilityAreaModel?.selectedTab = .debugConsole
        taskManager.taskShowingOutput = taskManager.selectedTaskID
    }
}
