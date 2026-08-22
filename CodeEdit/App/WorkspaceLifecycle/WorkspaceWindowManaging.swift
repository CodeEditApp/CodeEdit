//
//  WorkspaceWindowManaging.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 06.04.26.
//

import Foundation

/// Protocol for workspace window lifecycle management.
/// Enables testability by abstracting the window manager.
protocol WorkspaceWindowManaging: AnyObject {
    var openWorkspaces: [Workspace] { get }
    func openWorkspace(at url: URL) throws
    func closeWorkspace(_ workspace: Workspace)
    func workspace(containing url: URL) -> Workspace?
    func openFileInWorkspace(url: URL, asTemporary: Bool) -> Bool

    /// Presents an open panel and opens the chosen workspace or file.
    func openDocumentFromPanel()
    /// Presents a save panel, creates the file, and opens it.
    func newDocumentFromPanel()
    /// Opens a workspace or file at the given URL, calling the completion handler on success.
    func openDocument(at url: URL, onCompletion: @escaping () -> Void)
    /// Opens a dialog to choose a file or folder. (The concrete implementation
    /// provides default argument values; protocol requirements cannot.)
    func openDocumentWithDialog(
        canChooseFiles: Bool,
        canChooseDirectories: Bool,
        onDialogPresented: (() -> Void)?,
        onCancel: (() -> Void)?
    )
}

extension WorkspaceWindowManaging {
    /// Convenience: open non-temporarily. Keeps existing `openFileInWorkspace(url:)` call sites working.
    func openFileInWorkspace(url: URL) -> Bool {
        openFileInWorkspace(url: url, asTemporary: false)
    }
}
