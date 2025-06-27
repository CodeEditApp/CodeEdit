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
final class UndoManagerRegistration: ObservableObject {
    private var managerMap: [CEWorkspaceFile.ID: CEUndoManager] = [:]

    init() { }

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
