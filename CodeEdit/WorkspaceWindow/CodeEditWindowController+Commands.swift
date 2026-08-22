//
//  CodeEditWindowController+Commands.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 31/07/26.
//

import SwiftUI

extension CodeEditWindowController {
    /// These are example items that added as commands to command palette
    func registerCommands() {
        let commandManager = dependencies.commandManager
        commandManager.addCommand(
            name: "Quick Open",
            title: "Quick Open",
            id: "quick_open",
            command: { [weak self] in self?.openQuickly(nil) }
        )

        commandManager.addCommand(
            name: "Toggle Navigator",
            title: "Toggle Navigator",
            id: "toggle_left_sidebar",
            command: { [weak self] in self?.toggleFirstPanel() }
        )

        commandManager.addCommand(
            name: "Toggle Inspector",
            title: "Toggle Inspector",
            id: "toggle_right_sidebar",
            command: { [weak self] in self?.toggleLastPanel() }
        )
    }
}
