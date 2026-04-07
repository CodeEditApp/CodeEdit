//
//  SourceControlManager+Repository.swift
//  CodeEdit
//
//  Created by Austin Condiff on 7/2/24.
//

import Foundation

/// Repository-level git operations.
extension SourceControlManager {
    /// Validate repository
    func validate() async throws {
        let isGitRepository = await gitClient.validate()
        await MainActor.run {
            self.isGitRepository = isGitRepository
        }
    }

    /// Initiate repository
    func initiate() async throws {
        try await gitClient.initiate()
    }
}
