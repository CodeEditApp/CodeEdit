//
//  GitClient+CommitHistory.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/20/23.
//

import Foundation

extension GitClient {
    /// Gets the commit history log for the specified branch or file
    /// - Parameters:
    ///   - branchName: Name of the branch
    ///   - maxCount: Maximum amount of entries to get
    ///   - fileLocalPath: Optional path of file to get history for
    /// - Returns: Array of git commits
    func getCommitHistory(
        branchName: String? = nil,
        maxCount: Int? = nil,
        fileLocalPath: String? = nil
    ) async throws -> [GitCommit] {
        var branchNameString = ""
        var maxCountString = ""
        let fileLocalPath = fileLocalPath?.escapedWhiteSpaces() ?? ""
        if let branchName { branchNameString = "--first-parent \(branchName)" }
        if let maxCount { maxCountString = "-n \(maxCount)" }
        let dateFormatter = DateFormatter()

        // Can't use `Locale.current`, since it'd give a nil date outside the US
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"

        let output = try await run(
            "log --pretty=%h¦%H¦%s¦%aN¦%ae¦%cn¦%ce¦%aD¦ \(maxCountString) \(branchNameString) \(fileLocalPath)"
                .trimmingCharacters(in: .whitespacesAndNewlines)
        )

        let remote = try? await run("ls-remote --get-url")
        let remoteURL: URL? = if let remote {
             URL(string: remote.trimmingCharacters(in: .whitespacesAndNewlines))
        } else {
            nil
        }

        return output
            .split(separator: "\n")
            .map { line -> GitCommit in
                let parameters = line.components(separatedBy: "¦")
                return GitCommit(
                    hash: parameters[safe: 0] ?? "",
                    commitHash: parameters[safe: 1] ?? "",
                    message: parameters[safe: 2] ?? "",
                    author: parameters[safe: 3] ?? "",
                    authorEmail: parameters[safe: 4] ?? "",
                    committer: parameters[safe: 5] ?? "",
                    committerEmail: parameters[safe: 6] ?? "",
                    remoteURL: remoteURL,
                    date: dateFormatter.date(from: parameters[safe: 7] ?? "") ?? Date()
                )
            }
    }
}
