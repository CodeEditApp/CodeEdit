//
//  GitStatusChangedEvent.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom on 06/07/2026.
//

import Foundation

/// A snapshot of the current git status for every changed file in a workspace,
/// published by source control and consumed by the workspace file manager, which
/// applies the statuses onto its cached files and clears any file not present here.
public struct GitStatusChangedEvent: Event {
    /// Restricts delivery to the workspace at this URL.
    public let workspaceURL: URL

    /// fileKey → status for every currently-changed file. The file manager clears
    /// `gitStatus` on any cached file whose key is NOT present in this map.
    public let changed: [String: GitStatus]

    public init(workspaceURL: URL, changed: [String: GitStatus]) {
        self.workspaceURL = workspaceURL
        self.changed = changed
    }
}
