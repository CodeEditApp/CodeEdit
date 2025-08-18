//
//  PackageManagerProgressModel.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/8/25.
//

import Foundation
import Combine

/// This model is injected into each ``PackageManagerInstallStep`` when executing a ``PackageManagerInstallOperation``.
/// A single model is used for each step. Output is collected by the ``PackageManagerInstallOperation``.
///
/// Yields output into an async stream, and provides common helper methods for exec-ing commands, creating
/// directories, etc.
@MainActor
final class PackageManagerProgressModel: ObservableObject {
    enum OutputItem {
        case status(String)
        case output(String)
    }

    let outputStream: AsyncStream<OutputItem>
    @Published var progress: Progress

    private let shellClient: ShellClient
    private let outputContinuation: AsyncStream<OutputItem>.Continuation

    init(shellClient: ShellClient) {
        self.shellClient = shellClient
        self.progress = Progress(totalUnitCount: 1)
        (outputStream, outputContinuation) = AsyncStream<OutputItem>.makeStream()
    }

    func status(_ string: String) {
        outputContinuation.yield(.status(string))
    }

    /// Creates the directory for the language server to be installed in
    func createDirectoryStructure(for packagePath: URL) throws {
        let decodedPath = packagePath.path(percentEncoded: false)
        if FileManager.default.fileExists(atPath: decodedPath) {
            status("Removing existing installation.")
            try FileManager.default.removeItem(at: packagePath)
        }

        status("Creating directory: \(decodedPath)")
        try FileManager.default.createDirectory(
            at: packagePath,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }

    /// Executes commands in the specified directory
    @discardableResult
    func executeInDirectory(in packagePath: String, _ args: [String]) async throws -> [String] {
        return try await runCommand("cd \"\(packagePath)\" && \(args.joined(separator: " "))")
    }

    /// Runs a shell command and returns output
    @discardableResult
    func runCommand(_ command: String) async throws -> [String] {
        var output: [String] = []
        status("\(command)")
        for try await line in shellClient.runAsync(command) {
            output.append(line)
            outputContinuation.yield(.output(line))
        }
        return output
    }

    func finish() {
        outputContinuation.finish()
        progress.completedUnitCount = progress.totalUnitCount
    }
}
