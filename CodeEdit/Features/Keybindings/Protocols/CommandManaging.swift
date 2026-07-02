//
//  CommandManaging.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 11/04/26.
//

import Foundation
import CodeEditCore

/// Protocol for managing application commands (command palette).
protocol CommandManaging: AnyObject {
    var commands: [Command] { get }
    func addCommand(name: String, title: String, id: String, command: @escaping () -> Void)
    func executeCommand(_ id: String)
}
