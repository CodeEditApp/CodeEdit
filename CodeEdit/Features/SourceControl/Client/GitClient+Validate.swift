//
//  GitClient+Validate.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/29/23.
//

import Foundation

extension GitClient {
    /// Determines if the current directory is a valid git repository.
    ///
    /// Runs `git rev-parse --is-inside-work-tree`.
    ///
    /// - Returns: True, if git finds a valid repository.
    func validate() async -> Bool {
        do {
            let output = try await run("rev-parse --is-inside-work-tree")
            return output.trimmingCharacters(in: .whitespacesAndNewlines) == "true"
        } catch {
            return false
        }
    }
}
