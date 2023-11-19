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

    /// Returns tuple of unsynced commits both ahead and behind
    func numberOfUnsyncedCommits() async throws -> (ahead: Int, behind: Int) {
        let output = try await run("for-each-ref --format=\"%(push:track)\" refs/heads")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return parseUnsyncedCommitsOutput(from: output)
    }
}

func parseUnsyncedCommitsOutput(from string: String) -> (ahead: Int, behind: Int) {
    let pattern = "\\[ahead (\\d+)?, behind (\\d+)?\\]|\\[ahead (\\d+)?\\]|\\[behind (\\d+)?\\]"
    let regex = try? NSRegularExpression(pattern: pattern, options: [])

    if let match = regex?.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count)) {
        let aheadRange = Range(match.range(at: 1), in: string) ?? Range(match.range(at: 3), in: string)
        let behindRange = Range(match.range(at: 2), in: string) ?? Range(match.range(at: 4), in: string)

        let aheadNumber = aheadRange.flatMap { Int(String(string[$0])) } ?? 0
        let behindNumber = behindRange.flatMap { Int(String(string[$0])) } ?? 0

        return (ahead: aheadNumber, behind: behindNumber)
    }

    return (ahead: 0, behind: 0)
}
