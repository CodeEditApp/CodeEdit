//
//  StartTaskToolbarItem.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/28/25.
//

import AppKit
import CETerminal

@available(macOS 26, *)
final class StartTaskToolbarItem: NSToolbarItem {
    private weak var workspace: Workspace?
    private weak var utilityAreaModel: UtilityAreaViewModel?
    private let commandManager: CommandManaging

    private var utilityAreaCollapsed: Bool {
        utilityAreaModel?.isCollapsed ?? true
    }

    init(workspace: Workspace, utilityAreaModel: UtilityAreaViewModel, commandManager: CommandManaging) {
        self.workspace = workspace
        self.utilityAreaModel = utilityAreaModel
        self.commandManager = commandManager
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
            commandManager.executeCommand("open.drawer")
        }
        utilityAreaModel?.selectedTabID = PanelTabID.debugConsole
        taskManager.taskShowingOutput = taskManager.selectedTaskID
    }
}
