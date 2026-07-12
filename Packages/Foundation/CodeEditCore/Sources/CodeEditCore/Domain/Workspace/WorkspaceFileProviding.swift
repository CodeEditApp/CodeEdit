//
//  WorkspaceFileProviding.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom on 12/07/2026.
//

import Foundation

/// Read-mostly access to a workspace's file tree, plus change observation.
///
/// The interface features program against; the implementation is the
/// `CEWorkspaceFileManager` service. Deliberately narrow — it carries only what
/// feature packages actually consume (path resolution, child listing, change
/// observation), not the mutating file-management API, which stays on the
/// concrete service for app-shell use.
public protocol WorkspaceFileProviding: AnyObject {
    /// The root folder of the workspace.
    var folderUrl: URL { get }

    /// Resolves a path to its file item, optionally indexing intermediate
    /// directories to find it.
    func getFile(_ path: String, createIfNotFound: Bool) -> CEWorkspaceFile?

    /// The cached children of a directory item, if loaded.
    func childrenOfFile(_ file: CEWorkspaceFile) -> [CEWorkspaceFile]?

    /// Registers an observer for file-tree changes. Observers are held weakly.
    func addObserver(_ observer: WorkspaceFileObserver)

    /// Removes a previously registered observer.
    func removeObserver(_ observer: WorkspaceFileObserver)
}

/// Receives file-tree change notifications from a ``WorkspaceFileProviding``.
public protocol WorkspaceFileObserver: AnyObject {
    func fileManagerUpdated(updatedItems: Set<CEWorkspaceFile>)
}
