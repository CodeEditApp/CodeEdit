//
//  CommandPaletteState.swift
//  CodeEdit
//
//  Created by Alex on 25.05.2022.
//

import Foundation
import Keybindings

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
        if self.filteredCommands.capacity > 0 {
            self.selected = self.filteredCommands.first
        }
    }
}
