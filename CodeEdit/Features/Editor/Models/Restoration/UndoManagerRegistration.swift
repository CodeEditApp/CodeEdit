//
//  UndoManagerRegistration.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/27/25.
//

import SwiftUI
import CodeEditTextView

/// Very simple class for registering undo manager for files for a project session. This does not do any saving, it
/// just stores the undo managers in memory and retrieves them as necessary for files.
///
/// Undo stacks aren't stored on `CEWorkspaceFile` or `CodeFileDocument` because:
/// - `CEWorkspaceFile` can be refreshed and reloaded at any point.
/// - `CodeFileDocument` is released once there are no editors viewing it.
/// Undo stacks need to be retained for the duration of a workspace session, enduring editor closes..
final class UndoManagerRegistration: ObservableObject {
    private var managerMap: [CEWorkspaceFile.ID: CEUndoManager] = [:]

    init() { }

    /// Find or create a new undo manager.
    /// - Parameter file: The file to create for.
    /// - Returns: The undo manager for the given file.
    func manager(forFile file: CEWorkspaceFile) -> CEUndoManager {
        if let manager = managerMap[file.id] {
            return manager
        } else {
            let newManager = CEUndoManager()
            managerMap[file.id] = newManager
            return newManager
        }
    }
}
