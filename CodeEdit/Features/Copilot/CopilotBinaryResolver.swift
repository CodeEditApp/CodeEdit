//
//  CopilotBinaryResolver.swift
//  CodeEdit
//
//  Created by Anas Khan on 6/30/26.
//

import Foundation

/// Locates the `copilot-language-server` binary and builds a launch environment for it.
enum CopilotBinaryResolver {
    private static let binaryName = "copilot-language-server"

    /// Resolves the path to the `copilot-language-server` binary.
    ///
    /// Prefers an explicit `configuredPath`, then searches `PATH` and common installation directories.
    static func resolveBinaryPath(configuredPath: String) -> String? {
        let fileManager = FileManager.default
        let trimmed = configuredPath.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty, fileManager.isExecutableFile(atPath: trimmed) {
            return trimmed
        }

        let home = fileManager.homeDirectoryForCurrentUser.path
        var searchDirectories: [String] = []
        if let path = ProcessInfo.processInfo.environment["PATH"] {
            searchDirectories.append(contentsOf: path.split(separator: ":").map(String.init))
        }
        searchDirectories.append(contentsOf: [
            "/opt/homebrew/bin",
            "/usr/local/bin",
            "/usr/bin",
            "\(home)/.npm-global/bin",
            "\(home)/.local/bin"
        ])

        for directory in searchDirectories {
            let candidate = (directory as NSString).appendingPathComponent(binaryName)
            if fileManager.isExecutableFile(atPath: candidate) {
                return candidate
            }
        }
        return nil
    }

    /// Builds an environment for the language-server process, ensuring `PATH` includes Node and the binary directory.
    ///
    /// The server's `#!/usr/bin/env node` shebang requires `node` to be discoverable on `PATH`, which is not
    /// guaranteed inside the sandboxed app, so nvm-managed and common Node directories are appended.
    static func augmentedEnvironment(forBinaryAt binaryPath: String) -> [String: String] {
        var environment = ProcessInfo.processInfo.environment
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let binaryDirectory = (binaryPath as NSString).deletingLastPathComponent
        var extraPaths = [
            binaryDirectory,
            "/opt/homebrew/bin",
            "/usr/local/bin",
            "/usr/bin",
            "/bin"
        ]

        let nvmNode = "\(home)/.nvm/versions/node"
        if let versions = try? FileManager.default.contentsOfDirectory(atPath: nvmNode) {
            extraPaths.append(contentsOf: versions.map { "\(nvmNode)/\($0)/bin" })
        }

        let currentPath = environment["PATH"] ?? ""
        let combined = ([currentPath] + extraPaths).filter { !$0.isEmpty }.joined(separator: ":")
        environment["PATH"] = combined
        return environment
    }
}
