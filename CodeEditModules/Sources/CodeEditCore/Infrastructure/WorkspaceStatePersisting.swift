//
//  WorkspaceStatePersisting.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom on 06.04.26.
//

import Foundation

public protocol WorkspaceStatePersisting: AnyObject {
    func get(_ key: WorkspaceStateKey) -> Any?
    func set(key: WorkspaceStateKey, value: Any?)
}
