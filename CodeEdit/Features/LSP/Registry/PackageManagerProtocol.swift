//
//  PackageManager.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/2/25.
//

import Foundation

protocol PackageManagerProtocol {
    var shellClient: ShellClient { get }

    /// Performs any initialization steps for installing a package, such as creating the directory
    /// and virtual environments.
    func initialize(in packagePath: URL) async throws
    /// Calls the shell commands to install a package
    func install(method installationMethod: InstallationMethod) async throws
    /// Gets the location of the binary that was installed
    func getBinaryPath(for package: String) -> String
    /// Checks if the shell commands for the package manager are available or not
    func isInstalled() async -> Bool
}

extension PackageManagerProtocol {
    /// Creates the directory for the language server to be installed in
    func createDirectoryStructure(for packagePath: URL) throws {
        let decodedPath = packagePath.path.removingPercentEncoding ?? packagePath.path
        if !FileManager.default.fileExists(atPath: decodedPath) {
            try FileManager.default.createDirectory(
                at: packagePath,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }

    /// Executes commands in the specified directory
    func executeInDirectory(in packagePath: String, _ args: [String]) async throws -> [String] {
        return try await runCommand("cd \"\(packagePath)\" && \(args.joined(separator: " "))")
    }

    /// Runs a shell command and returns output
    func runCommand(_ command: String) async throws -> [String] {
        var output: [String] = []
        for try await line in shellClient.runAsync(command) {
            output.append(line)
        }
        return output
    }
}

/// Generic package source information that applies to all installation methods.
/// Takes all the necessary information from `RegistryItem`.
struct PackageSource: Equatable, Codable {
    /// The raw source ID string from the registry
    let sourceId: String
    /// The type of the package manager
    let type: PackageManagerType
    /// Package name
    let pkgName: String
    /// The name in the registry.json file. Used for the folder name when saved.
    let entryName: String
    /// Package version
    let version: String
    /// URL for repository or download link
    let repositoryUrl: String?
    /// Git reference type if this is a git based package
    let gitReference: GitReference?
    /// Additional possible options
    var options: [String: String]

    init(
        sourceId: String,
        type: PackageManagerType,
        pkgName: String,
        entryName: String,
        version: String,
        repositoryUrl: String? = nil,
        gitReference: GitReference? = nil,
        options: [String: String] = [:]
    ) {
        self.sourceId = sourceId
        self.type = type
        self.pkgName = pkgName
        self.entryName = entryName
        self.version = version
        self.repositoryUrl = repositoryUrl
        self.gitReference = gitReference
        self.options = options
    }

    enum GitReference: Equatable, Codable {
        case tag(String)
        case revision(String)
    }
}
