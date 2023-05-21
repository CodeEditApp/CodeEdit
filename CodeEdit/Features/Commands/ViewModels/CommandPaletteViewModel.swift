//
//  CommandPaletteViewModel.swift
//  CodeEdit
//
//  Created by Alex on 25.05.2022.
//

import AppKit
import Combine

/// Simple state class for command palette view. Contains currently selected command,
/// query text and list of filtered commands
final class CommandPaletteViewModel: ObservableObject {

    @Published
    var commandQuery: String = ""

    @Published
    var filteredMenuCommands: [CodeEditCommand] = []

    var menubarWatcher: AnyCancellable?

    var commands: [CodeEditCommand]

    init() {
        commands = Self.aggregateAllMenuBarCommands()
        menubarWatcher = NSApp.publisher(for: \.mainMenu).sink { [weak self] _ in
            print("menu updated")
            self?.commands = Self.aggregateAllMenuBarCommands()
        }
    }

    func reset() {
        commandQuery = ""
    }

    func updateMenuBarCommands() {
        commands = Self.aggregateAllMenuBarCommands()
    }

    static func aggregateAllMenuBarCommands() -> [CodeEditCommand] {
        if let mainMenu = NSApp.mainMenu {
            return mainMenu
                .items
                .indices
                .compactMap { CodeEditCommand(\.items[$0]).subItems }
                .reduce([], +)
        }
        return []
    }

    func fetchMatchingCommands(filter: String) {
        filteredMenuCommands = commands.map { $0.matchingFilter(filter) }.reduce([], +)
    }
}
