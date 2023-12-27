//
//  GitClient+Commit.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/20/23.
//

import Foundation
import RegexBuilder

extension GitClient {
    /// Commit files
    /// - Parameters:
    ///   - message: Commit message
    func commit(message: String, details: String?) async throws {
        let message = message.replacingOccurrences(of: #"""#, with: #"\""#)
        let command: String

        if let msgDetails = details {
            command = "commit --message=\"\(message + (msgDetails.isEmpty ? "" : ("\n\n" + msgDetails)))\""
        } else {
            command = "commit --message=\"\(message)\""
        }

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
        let output = try await run("status -sb --porcelain=v2").trimmingCharacters(in: .whitespacesAndNewlines)
        return try parseUnsyncedCommitsOutput(from: output)
    }

    private func parseUnsyncedCommitsOutput(from string: String) throws -> (ahead: Int, behind: Int) {
        let components = string.components(separatedBy: .newlines)
        guard var abLine = components.first(where: { $0.starts(with: "# branch.ab") }) else {
            // We're using --porcelain, this shouldn't happen
            return (ahead: 0, behind: 0)
        }
        abLine = String(abLine.dropFirst("# branch.ab ".count))
        let regex = Regex {
            One("+")
            Capture {
                OneOrMore(.digit)
            } transform: { Int($0) }
            One(" -")
            Capture {
                OneOrMore(.digit)
            } transform: { Int($0) }
        }
        guard let match = try regex.firstMatch(in: abLine),
              let ahead = match.output.1,
              let behind = match.output.2 else {
            return (ahead: 0, behind: 0)
        }
        return (ahead: ahead, behind: behind)
    }
}
