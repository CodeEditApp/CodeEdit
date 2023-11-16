//
//  GitClient+Commit.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/20/23.
//

import Foundation

extension GitClient {
    /// Commit files
    /// - Parameters:
    ///   - message: Commit message
    func commit(_ message: String) async throws {
        let message = message.replacingOccurrences(of: #"""#, with: #"\""#)
        let command = "commit --message=\"\(message)\""

        _ = try await run(command)
    }

    /// Add file to git
    /// - Parameter file: File to add
    func add(_ files: [CEWorkspaceFile]) async throws {
        _ = try await run("add \(files.map { $0.url.relativePath }.joined(separator: " "))")
    }

    /// Add file to git
    /// - Parameter file: File to add
    func reset(_ files: [CEWorkspaceFile]) async throws {
        _ = try await run("reset \(files.map { $0.url.relativePath }.joined(separator: " "))")
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
