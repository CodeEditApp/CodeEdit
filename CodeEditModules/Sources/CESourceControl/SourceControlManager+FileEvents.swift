//
//  SourceControlManager+FileEvents.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 06/07/2026.
//

import Combine
import CodeEditSettings
import Foundation
import CodeEditCore

/// Interprets raw workspace filesystem events (published by the file manager) and
/// dispatches targeted git refreshes. This is where git-internals knowledge lives.
extension SourceControlManager {
    /// The distinct git refreshes a set of changed paths can imply.
    enum GitRefreshAction: CaseIterable {
        case changedFiles, stash, branches, currentBranch, remotes, validate
    }

    /// Pure classifier: maps changed workspace-relative paths to the set of git
    /// refreshes they require. `workspaceRelativePath` is the workspace root's
    /// `URL.relativePath` (used to anchor `.git/…` checks).
    nonisolated static func gitRefreshActions(
        for paths: [String],
        workspaceRelativePath root: String
    ) -> Set<GitRefreshAction> {
        var actions: Set<GitRefreshAction> = []

        let hasNonGitChanges = paths.contains(where: { !$0.contains(".git/") })
        let hasIndexChange = paths.contains("\(root)/.git/index")
        if hasNonGitChanges || hasIndexChange {
            actions.insert(.changedFiles)
        }
        if paths.contains("\(root)/.git/refs/stash") {
            actions.insert(.stash)
        }
        if paths.contains(where: { $0.contains("\(root)/.git/refs/heads") }) {
            actions.insert(.branches)
        }
        if paths.contains(where: { $0.contains("\(root)/.git/HEAD") }) {
            actions.insert(.currentBranch)
        }
        if paths.contains("\(root)/.git/config") {
            actions.insert(.remotes)
        }
        if paths.contains("\(root)/.git") {
            actions.insert(.validate)
        }
        return actions
    }

    /// Subscribe to workspace file events for this workspace. Call once from `init`.
    func subscribeToWorkspaceFileEvents() {
        eventBus.subscribe(WorkspaceFileEvent.self)
            .filter { [weak self] in $0.workspaceURL == self?.workspaceURL }
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                self?.handleWorkspaceFileEvent(event)
            }
            .store(in: &fileEventCancellables)
    }

    private func handleWorkspaceFileEvent(_ event: WorkspaceFileEvent) {
        switch event.kind {
        case .childrenIndexed:
            Task { await self.refreshAllChangedFiles() }
        case let .filesystemChanged(paths):
            let settings = settingsReader.value(SourceControlSettings.self).general
            guard settings.sourceControlIsEnabled && settings.refreshStatusLocally else { return }
            dispatch(Self.gitRefreshActions(for: paths, workspaceRelativePath: workspaceURL.relativePath))
        }
    }

    private func dispatch(_ actions: Set<GitRefreshAction>) {
        if actions.contains(.changedFiles) { Task { await self.refreshAllChangedFiles() } }
        if actions.contains(.stash) { Task { try await self.refreshStashEntries() } }
        if actions.contains(.branches) { Task { await self.refreshBranches() } }
        if actions.contains(.currentBranch) { Task { await self.refreshCurrentBranch() } }
        if actions.contains(.remotes) { Task { try await self.refreshRemotes() } }
        if actions.contains(.validate) { Task { try await self.validate() } }
    }
}
