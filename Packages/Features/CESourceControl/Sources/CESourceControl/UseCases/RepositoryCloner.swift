//
//  RepositoryCloner.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 15/04/26.
//

import CodeEditCore
import Foundation

/// Validates and orchestrates a `git clone` operation, streaming progress to the caller.
final class RepositoryCloner {
    private let shellClient: ShellClientProtocol

    init(shellClient: ShellClientProtocol) {
        self.shellClient = shellClient
    }


    enum Failure: Error, LocalizedError {
        case gitNotInstalled
        case invalidUrl
        case directoryExists
        case directoryCreationFailed(Error)

        var errorDescription: String? {
            switch self {
            case .gitNotInstalled:
                return "Git installation not found. Ensure Git is installed on your system and try again."
            case .invalidUrl:
                return "Invalid repository URL."
            case .directoryExists:
                return "Directory already exists at the destination."
            case .directoryCreationFailed(let error):
                return "Failed to create folder: \(error.localizedDescription)"
            }
        }
    }

    /// Parses and sanitizes the user-entered URL string, returning the remote URL and the suggested repo folder name.
    func parse(repoUrl: String) throws -> (remoteUrl: URL, suggestedName: String) {
        guard !repoUrl.isEmpty, let remoteUrl = URL(string: repoUrl) else {
            throw Failure.invalidUrl
        }

        var name = remoteUrl.lastPathComponent
        if name.hasSuffix(".git") {
            name.removeLast(4)
        }

        return (remoteUrl, name)
    }

    /// Verifies Git is available on the system.
    func verifyGitInstalled() throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["git"]
        let pipe = Pipe()
        process.standardOutput = pipe
        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus != 0 {
                throw Failure.gitNotInstalled
            }
        } catch let error as Failure {
            throw error
        } catch {
            throw Failure.gitNotInstalled
        }
    }

    /// Creates the local directory and starts the clone, streaming progress.
    /// On error or task cancellation, the caller is responsible for cleanup via ``cleanup(localPath:)``.
    func execute(
        remoteUrl: URL,
        localPath: URL
    ) throws -> AsyncThrowingMapSequence<GitClient.LiveCommandStream, GitClient.CloneProgress> {
        var isDir: ObjCBool = true
        if FileManager.default.fileExists(atPath: localPath.relativePath, isDirectory: &isDir) {
            throw Failure.directoryExists
        }

        do {
            try FileManager.default.createDirectory(
                atPath: localPath.relativePath,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            throw Failure.directoryCreationFailed(error)
        }

        let gitClient = GitClient(directoryURL: localPath, shellClient: shellClient)
        return gitClient.cloneRepository(remoteUrl: remoteUrl, localPath: localPath)
    }

    /// Removes a partially-cloned directory after a failure or cancellation.
    func cleanup(localPath: URL) throws {
        try FileManager.default.removeItem(atPath: localPath.relativePath)
    }
}
