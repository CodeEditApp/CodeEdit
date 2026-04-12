//
//  CommandManager.swift
//
//  Created by Alex on 23.05.2022.
//

import Foundation
import CodeEditDomain

/**
The object of this class intended to be a hearth of command palette. This object only exists as singleton.
 In Order to access its instance use `CommandManager.shared`

```
 /* To add or execute command see snipper below */
let mgr = CommandManager.shared
let wrap = CommandClosureWrapper.init(closure: {
    print("testing closure")
})

mgr.addCommand(name: "test", command: wrap)
mgr.executeCommand("test")
 ```
 */

final class CommandManager: CommandManaging {
    @Published private var commandsList: [String: Command]

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
