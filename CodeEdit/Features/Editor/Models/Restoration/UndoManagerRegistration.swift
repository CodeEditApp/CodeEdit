//
//  UndoManagerRegistration.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/27/25.
//

import SwiftUI
import CEWorkspaceFileManager
import CodeEditCore
import CodeEditTextView

/// Very simple class for registering undo manager for files for a project session. This does not do any saving, it
/// just stores the undo managers in memory and retrieves them as necessary for files.
///
/// Undo stacks aren't stored on `CEWorkspaceFile` or `CodeFileDocument` because:
/// - `CEWorkspaceFile` can be refreshed and reloaded at any point.
/// - `CodeFileDocument` is released once there are no editors viewing it.
/// Undo stacks need to be retained for the duration of a workspace session, enduring editor closes..
final class UndoManagerRegistration: ObservableObject {
    private var managerMap: [String: CEUndoManager] = [:]

    /// Used to check whether a file still has an open document. Wired by `WorkspaceFactory`.
    weak var editorManager: EditorManager?

    init() { }

    /// Find or create a new undo manager.
    /// - Parameter file: The file to create for.
    /// - Returns: The undo manager for the given file.
    func manager(forFile file: CEWorkspaceFile) -> CEUndoManager {
        manager(forFile: file.url)
    }

    /// Find or create a new undo manager.
    /// - Parameter path: The path of the file to create for.
    /// - Returns: The undo manager for the given file.
    func manager(forFile path: URL) -> CEUndoManager {
        if let manager = managerMap[path.absolutePath] {
            return manager
        } else {
            let newManager = CEUndoManager()
            managerMap[path.absolutePath] = newManager
            return newManager
        }
    }

    /// Find or create a new undo manager.
    /// - Parameter path: The path of the file to create for.
    /// - Returns: The undo manager for the given file.
    func managerIfExists(forFile path: URL) -> CEUndoManager? {
        managerMap[path.absolutePath]
    }
}

extension UndoManagerRegistration: CEWorkspaceFileManagerObserver {
    /// Managers need to be cleared when the following is true:
    /// - The file is not open in any editors
    /// - The file is updated externally
    ///
    /// To handle this?
    /// - When we receive a file update, if the file is not open in any editors we clear the undo stack
    func fileManagerUpdated(updatedItems: Set<CEWorkspaceFile>) {
        for file in updatedItems where editorManager?.document(for: file) == nil {
            managerMap.removeValue(forKey: file.url.absolutePath)
        }
    }
}
