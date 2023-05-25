//
//  CommandsOverlayViewModel.swift
//  CodeEdit
//
//  Created by Alex on 25.05.2022.
//

import Combine
import SwiftUI

/// Simple state class for commands overlay view. Contains currently selected command,
/// query text and list of filtered commands
final class CommandsOverlayViewModel: ObservableObject {
    @ObservedObject
    var commandManager: CommandManager = .shared

    @Published
    var commandQuery: String = ""

    @Published
    var filteredMenuCommands: [CECommand] = []

    var commands: [CECommand] = []

    init() {
        getCommands()
    }

    func reset() {
        commandQuery = ""
    }

    func getCommands() {
        commands = commandManager.getAll()
    }

    func fetchMatchingCommands(filter: String) {
        if filter.isEmpty {
            filteredMenuCommands = commands
            return
        }

        filteredMenuCommands = commands.filter { $0.matchingFilter(filter) }
    }
}
