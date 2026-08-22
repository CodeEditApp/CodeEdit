//
//  WorkspaceFileEvent.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom on 06/07/2026.
//

import Foundation

/// A raw filesystem change under a workspace root, published by the workspace
/// file manager and consumed by features that react to file changes (e.g. source
/// control). The file manager is deliberately git-agnostic: it emits raw paths and
/// lets subscribers interpret them.
public struct WorkspaceFileEvent: Event {
    public enum Kind: Sendable {
        /// One or more paths under the workspace root changed on disk.
        /// Paths are workspace-relative, exactly as reported by the event stream.
        case filesystemChanged(paths: [String])
        /// A directory's children were lazily indexed into the file cache.
        case childrenIndexed
    }

    /// Restricts delivery to the workspace at this URL.
    public let workspaceURL: URL
    public let kind: Kind

    public init(workspaceURL: URL, kind: Kind) {
        self.workspaceURL = workspaceURL
        self.kind = kind
    }
}
