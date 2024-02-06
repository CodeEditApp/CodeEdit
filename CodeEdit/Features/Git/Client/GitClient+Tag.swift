//
//  GitClient+Tag.swift
//  CodeEdit
//
//  Created by Johnathan Baird on 2/6/24.
//

import Foundation

extension GitClient {
    /// Determines if the current directory is a valid git repository.
    ///
    /// Runs `git rev-parse --is-inside-work-tree`.
    ///
    /// - Returns: True, if git finds a valid repository.
    func createTag(tagName:String, commitHash: String,message: String?) async -> Bool {
        do {
            let output = try await run("tag -a \(tagName) \(commitHash) -m \(message ?? "")")
            return output.trimmingCharacters(in: .whitespacesAndNewlines) == "true"
        } catch {
            return false
        }
    }
    
    func fetchTags() async throws -> [String] {
        let output = try await run("tag")
        print(output)
        return [output]
    }
}
