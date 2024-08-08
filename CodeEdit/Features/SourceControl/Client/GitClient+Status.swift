//
//  GitClient+Status.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/20/23.
//

import Foundation

extension GitClient {
    /// Get changed files
    func getChangedFiles() async throws -> [GitChangedFile] {
        let output = try await run("status -s --porcelain -u")

        return try output
            .split(whereSeparator: \.isNewline)
            .map { line -> GitChangedFile in
                let paramData = line.trimmingCharacters(in: .whitespacesAndNewlines)
                let parameters = paramData.components(separatedBy: " ")

                let urlIndex = parameters.count > 2 ? 2 : 1

                guard let url = URL(string: parameters[safe: urlIndex] ?? String(describing: URLError.badURL)) else {
                    throw GitClientError.failedToDecodeURL
                }

                let gitType: GitType? = .init(rawValue: parameters[safe: 0] ?? "")
                let fullLink = self.directoryURL.appending(path: url.relativePath)

                return GitChangedFile(
                    changeType: gitType,
                    fileLink: fullLink
                )
            }
    }

    /// Get staged files
    func getStagedFiles() async throws -> [GitChangedFile] {
        let output = try await run("diff --name-status --cached")

        return try output
            .split(whereSeparator: \.isNewline)
            .map { line -> GitChangedFile in
                let paramData = line.trimmingCharacters(in: .whitespacesAndNewlines)
                let parameters = paramData.components(separatedBy: "\t")
                let urlIndex = parameters.count > 2 ? 2 : 1

                guard let url = URL(string: parameters[safe: urlIndex] ?? String(describing: URLError.badURL)) else {
                    throw GitClientError.failedToDecodeURL
                }

                let gitType: GitType? = .init(rawValue: parameters[safe: 0] ?? "")
                let fullLink = self.directoryURL.appending(path: url.relativePath)

                return GitChangedFile(
                    changeType: gitType,
                    fileLink: fullLink
                )
            }
    }

    /// Discard changes for file
    func discardChanges(for file: URL) async throws {
        _ = try await run("restore \(file.relativePath)")
    }

    /// Discard unstaged changes
    func discardAllChanges() async throws {
        _ = try await run("restore .")
    }
}
