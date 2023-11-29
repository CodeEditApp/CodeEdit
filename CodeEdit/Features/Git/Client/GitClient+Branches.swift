//
//  GitClient+Branches.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/20/23.
//

import Foundation

extension GitClient {
    /// Get branches
    /// - Returns: Array of branches
    func getBranches() async throws -> [GitBranch] {
        let command = "branch --format \"%(refname:short)|%(refname)|%(upstream:short)\" -a"

        return try await run(command)
            .components(separatedBy: "\n")
            .filter { $0 != "" && !$0.contains("HEAD") }
            .compactMap { line in
                let components = line.components(separatedBy: "|")
                let name = components[0]
                let upstream = components[safe: 2]

                return .init(
                    name: name,
                    longName: components[safe: 1] ?? name,
                    upstream: upstream?.isEmpty == true ? nil : upstream
                )
            }
    }

    /// Get current branch
    func getCurrentBranch() async throws -> GitBranch? {
        let branchName = try await run("rev-parse --abbrev-ref HEAD").trimmingCharacters(in: .whitespacesAndNewlines)
        let components = try await run(
            "for-each-ref --format=\"%(refname)|%(upstream:short)\" refs/heads/\(branchName)"
        )
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "|")

        let upstream = components[safe: 1]

        return .init(
            name: branchName,
            longName: components[0],
            upstream: upstream?.isEmpty == true ? nil : upstream
        )
    }

    /// Delete branch
    func deleteBranch(_ branch: GitBranch) async throws {
        if !branch.isLocal {
            return
        }

        _ = try await run("branch -d \(branch.name)")
    }

    /// Create new branch
    func newBranch(name: String, from: GitBranch) async throws {
        if !from.isLocal {
            return
        }

        _ = try await run("checkout -b \(name) \(from.name)")
    }

    /// Rename branch
    /// - Parameter from: Name of the branch to rename
    /// - Parameter to: New name for branch
    func renameBranch(from: String, to: String) async throws {
        _ = try await run("branch -m \(from) \(to)")
    }

    /// Checkout branch
    /// - Parameter branch: Branch to checkout
    func checkoutBranch(_ branch: GitBranch, forceLocal: Bool = false) async throws {
        var command = "checkout "

        // If branch is remote, try to create local branch
        if branch.isRemote {
            let localName = branch.name.replacingOccurrences(of: "origin/", with: "")
            command += forceLocal ? localName : "-b " + localName + " " + branch.name
        } else {
            command += branch.name
        }

        do {
            let output = try await run(command)
            if !output.contains("Switched to branch") && !output.contains("Switched to a new branch") {
                throw GitClientError.outputError(output)
            }
        } catch {
            // If branch is remote and command failed because branch already exists
            // try to switch to local branch
            if let error = error as? GitClientError,
               branch.isRemote,
               error.localizedDescription.contains("already exists") {
                try await checkoutBranch(branch, forceLocal: true)
            }
        }
    }
}
