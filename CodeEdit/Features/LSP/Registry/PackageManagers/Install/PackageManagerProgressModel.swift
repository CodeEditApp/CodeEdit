//
//  PackageManagerProgressModel.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/8/25.
//

import Foundation
import Combine

@MainActor
final class PackageManagerProgressModel: ObservableObject {
    let outputStream: AsyncStream<String>
    @Published var progress: Progress

    private let shellClient: ShellClient
    private let outputContinuation: AsyncStream<String>.Continuation

    init(shellClient: ShellClient) {
        self.shellClient = shellClient
        self.progress = Progress(totalUnitCount: 1)
        (outputStream, outputContinuation) = AsyncStream<String>.makeStream()
    }

    func status(_ string: String) {
        outputContinuation.yield(string)
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
    func executeInDirectory(in packagePath: String, _ args: [String]) async throws -> [String] {
        return try await runCommand("cd \"\(packagePath)\" && \(args.joined(separator: " "))")
    }

    /// Runs a shell command and returns output
    func runCommand(_ command: String) async throws -> [String] {
        var output: [String] = []
        status("Executing: \(command)")
        for try await line in shellClient.runAsync(command) {
            output.append(line)
            outputContinuation.yield(line)
        }
        return output
    }

    func finish() {
        outputContinuation.finish()
        progress.completedUnitCount = progress.totalUnitCount
    }
}
