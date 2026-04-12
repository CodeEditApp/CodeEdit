//
//  WorkspaceStatePersisting.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 06.04.26.
//

import Foundation

/// Protocol for workspace state persistence, enabling mock implementations for testing.
protocol WorkspaceStatePersisting: AnyObject {
    func get(_ key: WorkspaceStateKey) -> Any?
    func set(key: WorkspaceStateKey, value: Any?)
}
