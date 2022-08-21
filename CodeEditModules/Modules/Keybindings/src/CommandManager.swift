//
//  CommandManager.swift
//
//  Created by Alex on 23.05.2022.
//

import Foundation
import WorkspaceClient

/**
The object of this class intented to be a hearth of command palette. This object only exists as singleton.
 In Order to access its instance use `CommandManager.shared`

```
 /* To add or execute command see snipper below */
let mgr = CommandManager.shared
let wrap = ClosureWrapper.init(closure: {
    print("testing closure")
})

mgr.addCommand(name: "test", command: wrap)
mgr.executeCommand(name: "test")
 ```
 */

public final class CommandManager: ObservableObject {
    @Published private var commandsList: [String: Command]

    private init() {
        commandsList = [:]
    }

    public static let shared: CommandManager = .init()

    public func addCommand(name: String, title: String, id: String, command: ClosureWrapper) {
        let command = Command.init(id: name, title: title, closureWrapper: command)
        commandsList[id] = command
    }

    public var commands: [Command] {
        return commandsList.map { $0.value }
    }

    public func executeCommand(name: String) {
        commandsList[name]?.closureWrapper.call()
    }
}

/// Command struct uses as a wrapper for command. Used by command palette to call selected commands.
public struct Command: Identifiable, Hashable {

    public static func == (lhs: Command, rhs: Command) -> Bool {
        return lhs.id == rhs.id
    }

    static func < (lhs: Command, rhs: Command) -> Bool {
        return false
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public let id: String
    public let title: String
    public let closureWrapper: ClosureWrapper
    public init(id: String, title: String, closureWrapper: ClosureWrapper) {
        self.id = id
        self.title = title
        self.closureWrapper = closureWrapper
    }
}

/// A typealias of interface used for command closure declaration
public typealias WorkspaceClientClosure = () -> Void
/// A simple wrapper for command closure
public struct ClosureWrapper {

    let workspaceClientClosure: WorkspaceClientClosure?
    /// Initializer for closure wrapper
    /// - Parameter closure: Function that containts all logic to run command.
    public init(closure: @escaping WorkspaceClientClosure) {
       self.workspaceClientClosure = closure
    }
    // swiftlint:disable missing_docs
    public func call() {
        workspaceClientClosure?()
    }
}
