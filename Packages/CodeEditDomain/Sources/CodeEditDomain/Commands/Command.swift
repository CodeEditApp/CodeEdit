//
//  Command.swift
//  CodeEditDomain
//
//  Created by Matthijs Eikelenboom on 12/04/26.
//

import Foundation

/// Command struct uses as a wrapper for command. Used by command palette to call selected commands.
public struct Command: Identifiable, Hashable {

    public static func == (lhs: Command, rhs: Command) -> Bool {
        return lhs.id == rhs.id
    }

    public static func < (lhs: Command, rhs: Command) -> Bool {
        return false
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public let id: String
    public let title: String
    public let closureWrapper: () -> Void

    public init(id: String, title: String, closureWrapper: @escaping () -> Void) {
        self.id = id
        self.title = title
        self.closureWrapper = closureWrapper
    }
}
