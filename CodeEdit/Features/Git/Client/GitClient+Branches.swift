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
        let command = "branch --format \"%(refname:short)|%(refname)|%(upstream:short) %(upstream:track)\" -a"

        return try await run(command)
            .components(separatedBy: "\n")
            .filter { $0 != "" && !$0.contains("HEAD") }
            .compactMap { line in
                guard let branchPart = line.components(separatedBy: " ").first else { return nil }
                let branchComponents = branchPart.components(separatedBy: "|")
                let name = branchComponents[0]
                let upstream = branchComponents[safe: 2]

                let trackInfoString = line
                    .dropFirst(branchPart.count)
                    .trimmingCharacters(in: .whitespacesWithoutNewlines)
                let trackInfo = parseBranchTrackInfo(from: trackInfoString)

                return .init(
                    name: name,
                    longName: branchComponents[safe: 1] ?? name,
                    upstream: upstream?.isEmpty == true ? nil : upstream,
                    ahead: trackInfo.ahead,
                    behind: trackInfo.behind
                )
            }
    }

    /// Get current branch
    func getCurrentBranch() async throws -> GitBranch? {
        let branchName = try await run("branch --show-current").trimmingCharacters(in: .whitespacesAndNewlines)
        let output = try await run(
            "for-each-ref --format=\"%(refname)|%(upstream:short) %(upstream:track)\" refs/heads/\(branchName)"
        )
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let branchPart = output.components(separatedBy: " ").first else { return nil }
        let branchComponents = branchPart.components(separatedBy: "|")
        let upstream = branchComponents[safe: 1]

        let trackInfoString = output
            .dropFirst(branchPart.count)
            .trimmingCharacters(in: .whitespacesWithoutNewlines)
        let trackInfo = parseBranchTrackInfo(from: trackInfoString)

        return .init(
            name: branchName,
            longName: branchComponents[0],
            upstream: upstream?.isEmpty == true ? nil : upstream,
            ahead: trackInfo.ahead,
            behind: trackInfo.behind
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
    func renameBranch(oldName: String, newName: String) async throws {
        _ = try await run("branch -m \(oldName) \(newName)")
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

    private func parseBranchTrackInfo(from infoString: String) -> (ahead: Int, behind: Int) {
        let pattern = "\\[ahead (\\d+)(?:, behind (\\d+))?\\]|\\[behind (\\d+)\\]"
        // Create a regular expression object
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            fatalError("Invalid regular expression pattern")
        }
        var ahead = 0
        var behind = 0
        // Match the input string with the regular expression
        if let match = regex.firstMatch(
            in: infoString,
            options: [],
            range: NSRange(location: 0, length: infoString.utf16.count)
        ) {
            // Extract the captured groups
            if let aheadRange = Range(match.range(at: 1), in: infoString),
               let aheadValue = Int(infoString[aheadRange]) {
                ahead = aheadValue
            }
            if let behindRange = Range(match.range(at: 2), in: infoString),
               let behindValue = Int(infoString[behindRange]) {
                behind = behindValue
            }
            if let behindRange = Range(match.range(at: 3), in: infoString),
               let behindValue = Int(infoString[behindRange]) {
                behind = behindValue
            }
        }
        return (ahead, behind)
    }
}
