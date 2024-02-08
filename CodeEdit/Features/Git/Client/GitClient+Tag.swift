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
    func createTag(tagName: String, commitHash: String, message: String?) async -> Bool {
        do {
            let output = try await run("tag -a \(tagName) \(commitHash) -m \(message ?? "")")
            return output.trimmingCharacters(in: .whitespacesAndNewlines) == "true"
        } catch {
            return false
        }
    }

    func getTags() async throws -> [GitTag] {
        do {
            let output = try await run("for-each-ref refs/tags --format='%(refname:short) %(objectname) %(taggername) <%(taggeremail)> %(taggerdate)'")
            var gitTags: [GitTag] = []
            let lines = output.components(separatedBy: "\n")
            for line in lines where !line.isEmpty {
                // First, separate the line by the known structure "<email> <date>",
                // which allows us to isolate the taggerName even if it contains spaces.
                if let emailStartIndex = line.firstIndex(of: "<"),
                   let emailEndIndex = line.firstIndex(of: ">") {
                    let beforeEmail = line[..<emailStartIndex]
                    let email = line[emailStartIndex...emailEndIndex]
                    let afterEmail = line[line.index(after: emailEndIndex)...]
                    let beforeEmailComponents = beforeEmail.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true).map(String.init)
                    if beforeEmailComponents.count >= 2 {
                        let name = beforeEmailComponents[0]
                        let hash = beforeEmailComponents[1]
                        let taggerName = beforeEmailComponents.dropFirst(2).joined(separator: " ")
                        let tag = GitTag(name: name,
                                         hash: hash,
                                         taggerName: taggerName,
                                         taggerEmail: String(email).trimmingCharacters(in: CharacterSet(charactersIn: "<>")),
                                         dateCreated: String(afterEmail.trimmingCharacters(in: .whitespaces).dropFirst(2)))
                        gitTags.append(tag)
                    }
                }
            }
            print(gitTags)
            return gitTags
        } catch {
            print("Failed to execute git command: \(error)")
            return []
        }
    }
}
