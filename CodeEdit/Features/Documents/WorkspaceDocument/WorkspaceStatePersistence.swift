//
//  WorkspaceStatePersistence.swift
//  CodeEdit
//
//  Created by CodeEdit Contributors on 25.03.26.
//

import Foundation

/// A standalone service for persisting workspace-specific UI state (window size, collapsed panels, etc.)
/// via UserDefaults. Extracted from WorkspaceDocument to enable independent injection and testing.
final class WorkspaceStatePersistence: ObservableObject {
    private let workspaceURL: URL

    private var workspaceState: [String: Any] {
        get {
            let key = "workspaceState-\(workspaceURL.absoluteString)"
            return UserDefaults.standard.object(forKey: key) as? [String: Any] ?? [:]
        }
        set {
            let key = "workspaceState-\(workspaceURL.absoluteString)"
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    init(workspaceURL: URL) {
        self.workspaceURL = workspaceURL
    }

    func get(_ key: WorkspaceStateKey) -> Any? {
        workspaceState[key.rawValue]
    }

    func set(key: WorkspaceStateKey, value: Any?) {
        if let value {
            workspaceState.updateValue(value, forKey: key.rawValue)
        } else {
            workspaceState.removeValue(forKey: key.rawValue)
        }
    }
}
