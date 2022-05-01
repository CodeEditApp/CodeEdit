//
//  Live.swift
//  CodeEditModules/GitClient
//
//  Created by Marco Carnevali on 21/03/22.
//

import Foundation
import ShellClient

public extension GitClient {
    // swiftlint:disable function_body_length
    static func `default`(
        directoryURL: URL,
        shellClient: ShellClient
    ) -> GitClient {
        func getBranches(_ allBranches: Bool = false) throws -> [String] {
            if allBranches == true {
                return try shellClient.run(
                    "cd \(directoryURL.relativePath.escapedWhiteSpaces());git branch -a --format \"%(refname:short)\""
                )
                    .components(separatedBy: "\n")
                    .filter { $0 != "" }
            }
            return try shellClient.run(
                "cd \(directoryURL.relativePath.escapedWhiteSpaces());git branch --format \"%(refname:short)\""
            )
                .components(separatedBy: "\n")
                .filter { $0 != "" }
        }

        func getCurrentBranchName() throws -> String {
            let output = try shellClient.run(
                "cd \(directoryURL.relativePath.escapedWhiteSpaces());git rev-parse --abbrev-ref HEAD"
            )
                .replacingOccurrences(of: "\n", with: "")
            if output.contains("fatal: not a git repository") {
                throw GitClientError.notGitRepository
            }
            return output
        }

        func checkoutBranch(name: String) throws {
            guard try getCurrentBranchName() != name else { return }
            let output = try shellClient.run(
                "cd \(directoryURL.relativePath.escapedWhiteSpaces());git checkout \(name)"
            )
            if output.contains("fatal: not a git repository") {
                throw GitClientError.notGitRepository
            } else if !output.contains("Switched to branch") && !output.contains("Switched to a new branch") {
                throw GitClientError.outputError(output)
            }
        }
        func cloneRepository(url: String) throws {
            let output = try shellClient.run("cd \(directoryURL.relativePath.escapedWhiteSpaces());git clone \(url) .")
            if output.contains("fatal") {
                throw GitClientError.outputError(output)
            }
        }

        /// Gets the commit history log of the current file opened
        /// in the workspace.

        func getCommitHistory(entries: Int?, fileLocalPath: String?) throws -> [Commit] {
            var entriesString = ""
            let fileLocalPath = fileLocalPath?.escapedWhiteSpaces() ?? ""
            if let entries = entries { entriesString = "-n \(entries)" }
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
            let output = try shellClient.run(
                // swiftlint:disable:next line_length
                "cd \(directoryURL.relativePath.escapedWhiteSpaces());git log --pretty=%h¦%H¦%s¦%aN¦%ae¦%cn¦%ce¦%aD¦ \(entriesString) \(fileLocalPath)"
            )
            let remote = try shellClient.run(
                "cd \(directoryURL.relativePath.escapedWhiteSpaces());git ls-remote --get-url"
            )
            let remoteURL = URL(string: remote.trimmingCharacters(in: .whitespacesAndNewlines))
            if output.contains("fatal: not a git repository") {
                throw GitClientError.notGitRepository
            }
            return output
                .split(separator: "\n")
                .map { line -> Commit in
                    let parameters = line.components(separatedBy: "¦")
                    return Commit(
                        hash: parameters[safe: 0] ?? "",
                        commitHash: parameters[safe: 1] ?? "",
                        message: parameters[safe: 2] ?? "",
                        author: parameters[safe: 3] ?? "",
                        authorEmail: parameters[safe: 4] ?? "",
                        commiter: parameters[safe: 5] ?? "",
                        commiterEmail: parameters[safe: 6] ?? "",
                        remoteURL: remoteURL,
                        date: dateFormatter.date(from: parameters[safe: 7] ?? "") ?? Date()
                    )
                }
        }

        return GitClient(
            getCurrentBranchName: getCurrentBranchName,
            getBranches: getBranches(_:),
            checkoutBranch: checkoutBranch(name:),
            pull: {
                let output = try shellClient.run(
                    "cd \(directoryURL.relativePath);git pull"
                )
                if output.contains("fatal: not a git repository") {
                    throw GitClientError.notGitRepository
                }
            },
            cloneRepository: cloneRepository(url:),
            getCommitHistory: getCommitHistory(entries:fileLocalPath:)
        )
    }
}

private extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

private extension String {
    func escapedWhiteSpaces() -> String {
        self.replacingOccurrences(of: " ", with: "\\ ")
    }
}
