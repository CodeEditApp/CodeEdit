//
//  SourceControlViewModel.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 02/07/2026.
//

import Foundation
import CodeEditCore

/// Manages UI presentation state for the SourceControl feature.
///
/// Domain state (branches, changed files, remotes, etc.) lives in ``SourceControlManager``.
/// This view model owns only ephemeral UI state: which sheets are presented,
/// alert flags, and the shared operation fields used by the push and pull sheets.
@MainActor
public final class SourceControlViewModel: ObservableObject {
    public init() {}

    // MARK: - Sheet State

    /// Is the push sheet presented
    @Published public var pushSheetIsPresented: Bool = false {
        didSet { resetOperationFields() }
    }

    /// Is the pull sheet presented
    @Published public var pullSheetIsPresented: Bool = false {
        didSet { resetOperationFields() }
    }

    /// Is the fetch sheet presented
    @Published public var fetchSheetIsPresented: Bool = false

    /// Is the stash sheet presented
    @Published public var stashSheetIsPresented: Bool = false

    /// Is the remote sheet presented
    @Published public var addExistingRemoteSheetIsPresented: Bool = false

    /// Branch to switch to
    @Published public var switchToBranch: GitBranch?

    // MARK: - Operation Fields

    /// Branch selected for source control operations (shared between push and pull)
    @Published public var operationBranch: GitBranch?

    /// Remote selected for source control operations
    @Published public var operationRemote: GitRemote?

    /// Rebase boolean set for source control operations
    @Published public var operationRebase: Bool = false

    /// Force boolean set for source control operations
    @Published public var operationForce: Bool = false

    /// Include tags boolean set for source control operations
    @Published public var operationIncludeTags: Bool = false

    // MARK: - Alert State

    /// Is discard all alert presented
    @Published public var discardAllAlertIsPresented: Bool = false

    /// Is no changes to stage alert presented
    @Published public var noChangesToStageAlertIsPresented: Bool = false

    /// Is no changes to unstage alert presented
    @Published public var noChangesToUnstageAlertIsPresented: Bool = false

    /// Is no changes to stash alert presented
    @Published public var noChangesToStashAlertIsPresented: Bool = false

    /// Is no changes to discard alert presented
    @Published public var noChangesToDiscardAlertIsPresented: Bool = false

    // MARK: - Private

    private func resetOperationFields() {
        operationBranch = nil
        operationRemote = nil
        operationRebase = false
        operationForce = false
        operationIncludeTags = false
    }
}
