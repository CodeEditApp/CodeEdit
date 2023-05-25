//
//  CommandManager.swift
//
//  Created by Alex on 23.05.2022.
//
import SwiftUI

/**
The object of this class intended to be a hearth of command palette. This object only exists as singleton.
 In Order to access its instance use `CommandManager.shared`
```
 /* To add or execute command see snipper below */
let commandManager = CommandManager.shared
commandManager.register("test", label: "Test", action: wrap)
commandManager.execute("test")
 ```
 */

final class CommandManager: ObservableObject {
    @Published private var commands: [String: CECommand]

    private init() {
        commands = [:]
    }

    static let shared: CommandManager = .init()

    func register(
        _ id: String,
        label: String,
        keyboardShortcut: KeyboardShortcut? = nil,
        action: @escaping () -> Void
    ) {
        let command = CECommand.init(id: id, label: label, keyboardShortcut: keyboardShortcut, action: action)
        commands[id] = command
    }

    func get(_ id: String) -> CECommand? {
        return commands[id] ?? nil
    }

    func getAll() -> [CECommand] {
        return commands.map { $0.value }
    }

    func execute(_ id: String) {
        commands[id]?.action()
    }
}

/// Command struct uses as a wrapper for command. Used by command palette to call selected commands.
struct CECommand: Identifiable, Hashable {
    static func == (lhs: CECommand, rhs: CECommand) -> Bool {
        return lhs.id == rhs.id
    }

    static func < (lhs: CECommand, rhs: CECommand) -> Bool {
        return false
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id: String
    let label: String
    let keyboardShortcut: KeyboardShortcut?
    let action: () -> Void

    init(
        id: String,
        label: String,
        keyboardShortcut: KeyboardShortcut?,
        action: @escaping () -> Void
    ) {
        self.id = id
        self.label = label
        self.keyboardShortcut = keyboardShortcut
        self.action = action
    }

    func matchingFilter(_ filter: String) -> Bool {
        self.label.lowercased().contains(filter.lowercased())
    }
}

///// A simple wrapper for command closure
//struct CommandClosureWrapper {
//
//    /// A typealias of interface used for command closure declaration
//    typealias WorkspaceClientClosure = () -> Void
//
//    let workspaceClientClosure: WorkspaceClientClosure?
//
//    /// Initializer for closure wrapper
//    /// - Parameter closure: Function that contains all logic to run command.
//    init(closure: @escaping WorkspaceClientClosure) {
//       self.workspaceClientClosure = closure
//    }
//
//    func call() {
//        workspaceClientClosure?()
//    }
//}
