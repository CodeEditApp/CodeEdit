//
//  GitClient.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 26/11/2022.
//

import Combine
import Foundation

struct GitClient {
    enum GitClientError: Error {
        case outputError(String)
        case notGitRepository
        case failedToDecodeURL
    }

    enum CloneProgressResult {
        case receivingProgress(Int)
        case resolvingProgress(Int)
        case other(String)
    }

    private let directoryURL: URL
    private let shellClient: ShellClient

    init(directoryURL: URL, shellClient: ShellClient) {
        self.directoryURL = directoryURL
        self.shellClient = shellClient
    }

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

    func checkoutBranch(_ name: String) throws {
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

    func cloneRepository(url: String) -> AnyPublisher<CloneProgressResult, GitClientError> {
        shellClient
            .runLive("git clone \(url) \(directoryURL.relativePath.escapedWhiteSpaces()) --progress")
            .tryMap { output -> String in
                if output.contains("fatal: not a git repository") {
                    throw GitClientError.notGitRepository
                }
                return output
            }
            .map { value -> CloneProgressResult in
                // TODO: Make a more solid parsing system.
                if value.contains("Receiving objects: ") {
                    return .receivingProgress(
                        Int(
                            value
                                .replacingOccurrences(of: "Receiving objects: ", with: "")
                                .replacingOccurrences(of: " ", with: "")
                                .split(separator: "%")
                                .first ?? "0"
                        ) ?? 0
                    )
                } else if value.contains("Resolving deltas: ") {
                    return .resolvingProgress(
                        Int(
                            value
                                .replacingOccurrences(of: "Resolving deltas: ", with: "")
                                .replacingOccurrences(of: " ", with: "")
                                .split(separator: "%")
                                .first ?? "0"
                        ) ?? 0
                    )
                } else {
                    return .other(value)
                }
            }
            .mapError {
                if let error = $0 as? GitClientError {
                    return error
                } else {
                    return GitClientError.outputError($0.localizedDescription)
                }
            }
            .eraseToAnyPublisher()

    }

    func getChangedFiles() throws -> [ChangedFile] {
        let output = try shellClient.run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git status -s --porcelain -u"
        )
        if output.contains("fatal: not a git repository") {
            throw GitClientError.notGitRepository
        }
        return try output
            .split(whereSeparator: \.isNewline)
            .map { line -> ChangedFile in
                let paramData = line.trimmingCharacters(in: .whitespacesAndNewlines)
                let parameters = paramData.components(separatedBy: " ")
                guard let url = URL(string: parameters[safe: 1] ?? String(describing: URLError.badURL)) else {
                    throw GitClientError.failedToDecodeURL
                }

                var gitType: GitType {
                    .init(rawValue: parameters[safe: 0] ?? "") ?? GitType.unknown
                }

                return ChangedFile(changeType: gitType,
                                    fileLink: url)
            }
    }

    // Gets the commit history log of the current file opened
    // in the workspace.
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
}

private extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

private extension String {
    func escapedWhiteSpaces() -> String {
        self.replacingOccurrences(of: " ", with: "\\ ")
    }
}
