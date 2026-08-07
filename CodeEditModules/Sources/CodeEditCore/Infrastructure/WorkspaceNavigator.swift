//
//  WorkspaceNavigator.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom.
//

import Foundation

/// Command interface for opening a file in the workspace that owns it.
/// One rightful handler (the app shell binds it); features request, never resolve.
public protocol WorkspaceNavigator: AnyObject {
    /// Open `file` in its owning workspace's active editor.
    /// - Parameter asTemporary: open as a temporary (preview) tab, replaced by the next
    ///   temporary open, rather than a pinned tab.
    @MainActor
    func open(file: CEWorkspaceFile, asTemporary: Bool)

    /// Highlight `file` in the project navigator without opening it.
    @MainActor
    func reveal(file: CEWorkspaceFile)

    /// Close all tabs showing `file` across every editor split.
    @MainActor
    func closeTab(file: CEWorkspaceFile)
}

/// Default no-op used until the app registers a real implementation.
public final class NoOpWorkspaceNavigator: WorkspaceNavigator {
    public init() {}
    @MainActor
    public func open(file: CEWorkspaceFile, asTemporary: Bool) {}
    @MainActor
    public func reveal(file: CEWorkspaceFile) {}
    @MainActor
    public func closeTab(file: CEWorkspaceFile) {}
}
