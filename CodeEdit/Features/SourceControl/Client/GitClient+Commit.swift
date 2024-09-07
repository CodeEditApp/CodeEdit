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
    func add(_ files: [URL]) async throws {
        let output = try await run("add \(files.map { "'\($0.path(percentEncoded: false))'" }.joined(separator: " "))")
        print(output)
    }

    /// Add file to git
    /// - Parameter file: File to add
    func reset(_ files: [URL]) async throws {
        _ = try await run("reset \(files.map { "'\($0.path(percentEncoded: false))'" }.joined(separator: " "))")
    }

    /// Returns tuple of unsynced commits both ahead and behind
    func numberOfUnsyncedCommits() async throws -> (ahead: Int, behind: Int) {
        let output = try await run("status -sb --porcelain=v2").trimmingCharacters(in: .whitespacesAndNewlines)
        return try parseUnsyncedCommitsOutput(from: output)
    }

    func getCommitChangedFiles(commitSHA: String) async throws -> [GitChangedFile] {
        do {
            let output = try await run("diff-tree --no-commit-id --name-status -r \(commitSHA)")
            let data = output
                .trimmingCharacters(in: .newlines)
                .components(separatedBy: "\n")
            return try data.compactMap { line -> GitChangedFile? in
                let components = line.split(separator: "\t")
                guard components.count == 2 else { return nil }
                let changeType = String(components[0])
                let pathName = String(components[1])

                guard let url = URL(string: pathName ) else {
                    throw GitClientError.failedToDecodeURL
                }

                let gitType: GitStatus? = .init(rawValue: changeType)
                let fullLink = self.directoryURL.appending(path: url.relativePath)

                return GitChangedFile(
                    status: gitType ?? .none,
                    stagedStatus: .none,
                    fileURL: fullLink,
                    originalFilename: nil
                )
            }
        } catch {
            print("Error: \(error)")
            return []
        }
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
