//
//  CommandManager.swift
//
//  Created by Alex on 23.05.2022.
//

import Foundation
import WorkspaceClient

/// Usage
///
/**
```
let mgr = CommandManager.init()
let wrap = ClosureWrapper.init(closure: {
    print("testing closure")
})
mgr.addCommand(name: "test", command: wrap)
mgr.executeCommand(name: "test")
 ```
 */

public final class CommandManager {
    private var commandsList: [String: ClosureWrapper]
    public init() {
        commandsList = [:]
    }
    public func addCommand(name: String, command: ClosureWrapper) {
        commandsList[name] = command
    }

    public func executeCommand(name: String) {
        commandsList[name]?.call()
    }
}

public typealias WorkspaceClientClosure = () -> Void
public struct ClosureWrapper {

    let workspaceClientClosure: WorkspaceClientClosure?

    public init(closure: @escaping WorkspaceClientClosure) {
       self.workspaceClientClosure = closure
    }

    public func call() {
        workspaceClientClosure?()
    }
}
