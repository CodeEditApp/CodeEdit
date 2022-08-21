//
//  CommandPaletteState.swift
//  CodeEdit
//
//  Created by Alex on 25.05.2022.
//

import Foundation
import Keybindings

/// Simple state class for command palette view. Contains currently selected command,
/// query text and list of filtered commands

public final class CommandPaletteState: ObservableObject {
    @Published var commandQuery: String = ""
    @Published var selected: Command?
    @Published var isShowingCommandsList: Bool = true
    @Published var filteredCommands: [Command] = []

    func reset() {
        commandQuery = ""
        selected = nil
        filteredCommands = []
    }

    func fetchMatchingCommands(val: String) {
        if val == "" {
            self.filteredCommands = []
            return
        }
        self.filteredCommands = CommandManager.shared.commands.filter { $0.title.localizedCaseInsensitiveContains(val) }
        self.selected = self.filteredCommands.first

    }
}
