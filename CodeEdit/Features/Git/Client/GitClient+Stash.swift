//
//  GitClient+Stash.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/20/23.
//

import Foundation

extension GitClient {
    /// Add uncommited changes to stash
    func stash(message: String?) async throws {
        let command = message != nil ? "stash save --message=\"\(message ?? "")\"" : "stash"

        _ = try await self.run(command)
    }

    /// Pops the latest entry from stash onto HEAD
    func stashPop() async throws {
        let command = "stash pop"

        _ = try await self.run(command)
    }

    /// Lists all of the entries in stash
    func stashList() async throws -> [GitStashEntry] {
        let command = "stash list --date=local"
        let output = try await run(command)
        let stashEntries = parseGitStashEntries(output)

        return stashEntries
    }
}

func parseGitStashEntries(_ input: String) -> [GitStashEntry] {
    var entries: [GitStashEntry] = []

    let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
    let lines = trimmedInput.split(separator: "\n", omittingEmptySubsequences: false)

    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.current
    dateFormatter.dateFormat = "EEE MMM d HH:mm:ss yyyy"

    for (index, line) in lines.enumerated() {
        let components = line.split(separator: ": ", maxSplits: 2, omittingEmptySubsequences: true)
        guard components.count >= 3 else { continue }

        let dateString = String(components[0].replacingOccurrences(of: "stash@{", with: "").dropLast())
        guard let date = dateFormatter.date(from: dateString) else { continue }

        // Re-join the remaining parts of the message (if there are colons in the message)
        let message = components[2...].joined(separator: ": ").trimmingCharacters(in: .whitespaces)

        let entry = GitStashEntry(index: index, message: message, date: date)
        entries.append(entry)
    }

    return entries
}
