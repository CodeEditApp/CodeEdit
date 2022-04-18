//
//  Live.swift
//  CodeFile
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
        func getBranches() throws -> [String] {
            try shellClient.run(
                "cd \(directoryURL.relativePath);git branch --format \"%(refname:short)\""
            )
                .components(separatedBy: "\n")
                .filter { $0 != "" }
        }

        func getCurrentBranchName() throws -> String {
            let output = try shellClient.run(
                "cd \(directoryURL.relativePath);git rev-parse --abbrev-ref HEAD"
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
                "cd \(directoryURL.relativePath);git checkout \(name)"
            )
            if output.contains("fatal: not a git repository") {
                throw GitClientError.notGitRepository
            } else if !output.contains("Switched to branch") {
                throw GitClientError.outputError(output)
            }
        }
        func cloneRepository(url: String) throws {
            let output = try shellClient.run("cd \(directoryURL.relativePath);git clone \(url) .")
            if output.contains("fatal") {
                throw GitClientError.outputError(output)
            }
        }

        func getCommitHistory(entries: Int?, fileLocalPath: String?) throws -> [Commit] {
            var entriesString = ""
            let fileLocalPath = fileLocalPath ?? ""
            if let entries = entries { entriesString = "-n \(entries)" }
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
            return try shellClient.run(
                "cd \(directoryURL.relativePath);git log --pretty=%h¦%s¦%aN¦%aD¦ \(entriesString) \(fileLocalPath)"
            )
                .split(separator: "\n")
                .map { line -> Commit in
                    let parameters = line.components(separatedBy: "¦")
                    return Commit(
                        hash: parameters[safe: 0] ?? "",
                        message: parameters[safe: 1] ?? "",
                        author: parameters[safe: 2] ?? "",
                        date: dateFormatter.date(from: parameters[safe: 3] ?? "") ?? Date()
                    )
                }
        }

        return GitClient(
            getCurrentBranchName: getCurrentBranchName,
            getBranches: getBranches,
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
