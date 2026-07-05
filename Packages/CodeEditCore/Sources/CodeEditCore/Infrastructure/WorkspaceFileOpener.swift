//
//  WorkspaceFileOpener.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom on 05/07/2026.
//

import Foundation

/// Command interface for opening a file in the workspace that owns it.
/// One rightful handler (the app shell binds it); features request, never resolve.
public protocol WorkspaceFileOpener: AnyObject {
    @MainActor func openFile(at url: URL)
}

/// Default no-op used until the app registers a real implementation.
public final class NoOpWorkspaceFileOpener: WorkspaceFileOpener {
    public init() {}
    @MainActor public func openFile(at url: URL) {}
}
