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
}

extension WorkspaceWindowManaging {
    /// Convenience: open non-temporarily. Keeps existing `openFileInWorkspace(url:)` call sites working.
    func openFileInWorkspace(url: URL) -> Bool {
        openFileInWorkspace(url: url, asTemporary: false)
    }
}
