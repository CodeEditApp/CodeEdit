//
//  CommandManager.swift
//
//  Created by Alex on 23.05.2022.
//

import Foundation
import CodeEditCore

/// Registry backing the command palette. Owned by `AppDependencies`; objects receive it
/// through their initializer, views through the `\.commandManager` environment key.
final class CommandManager: CommandManaging {
    private var commandsList: [String: Command]

    init() {
        commandsList = [:]
    }

    func addCommand(name: String, title: String, id: String, command: @escaping () -> Void) {
        let command = Command.init(id: name, title: title, closureWrapper: command)
        commandsList[id] = command
    }

    var commands: [Command] {
        return commandsList.map { $0.value }
    }

    func executeCommand(_ id: String) {
        commandsList[id]?.closureWrapper()
    }
}
