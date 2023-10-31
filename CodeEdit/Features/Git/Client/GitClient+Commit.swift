//
//  GitClient+Commit.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/20/23.
//

import Foundation

extension GitClient {
    /// Commit files, if file is untracked, it will be added
    /// - Parameters:
    ///   - files: Files to commit
    ///   - message: Commit message
    func commit(_ files: [CEWorkspaceFile], message: String) async throws {
        // Add untracked files
        for file in files where file.gitStatus == .untracked {
            try await add(file)
        }

        let message = message.replacingOccurrences(of: #"""#, with: #"\""#)
        let command = "commit \(files.map { $0.url.relativePath }.joined(separator: " ")) --message=\"\(message)\""

        _ = try await run(command)
    }

    /// Add file to git
    /// - Parameter file: File to add
    func add(_ file: CEWorkspaceFile) async throws {
        if file.gitStatus != .untracked {
            return
        }

        _ = try await run("add \(file.url.relativePath)")
    }

    func numberOfUnsyncedCommits() async throws -> Int {
        let output = try await run("log --oneline origin/$(git rev-parse --abbrev-ref HEAD)..HEAD | wc -l")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let number = Int(output) {
            return number
        }

        return 0
    }
}
