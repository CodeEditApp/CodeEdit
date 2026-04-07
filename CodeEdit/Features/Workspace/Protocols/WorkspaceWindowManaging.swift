//
//  WorkspaceWindowManaging.swift
//  CodeEdit
//
//  Created by CodeEdit Contributors on 06.04.26.
//

import Foundation

/// Protocol for workspace window lifecycle management.
/// Enables testability by abstracting the window manager.
protocol WorkspaceWindowManaging: AnyObject {
    var openWorkspaces: [Workspace] { get }
    func openWorkspace(at url: URL) throws
    func closeWorkspace(_ workspace: Workspace)
    func workspace(containing url: URL) -> Workspace?
    func openFileInWorkspace(url: URL) -> Bool
}
