//
//  PackageManager.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/2/25.
//

import Foundation

protocol PackageManagerProtocol {
    var shellClient: ShellClient { get }

    func initialize(in packagePath: URL) async throws
    func install(method installationMethod: InstallationMethod) async throws
    func getBinaryPath(for package: String) -> String
    func isInstalled() async -> Bool
}

extension PackageManagerProtocol {
    /// Creates the directory for the language server to be installed in
    internal func createDirectoryStructure(for packagePath: URL) throws {
        if !FileManager.default.fileExists(atPath: packagePath.path) {
            try FileManager.default.createDirectory(
                at: packagePath,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }

    /// Executes commands in the specified directory
    internal func executeInDirectory(in packagePath: String, _ args: [String]) async throws -> [String] {
        return try await runCommand("cd \"\(packagePath)\" && \(args.joined(separator: " "))")
    }

    /// Runs a shell command and returns output
    internal func runCommand(_ command: String) async throws -> [String] {
        var output: [String] = []
        for try await line in shellClient.runAsync(command) {
            output.append(line)
        }
        return output
    }
}

enum PackageManagerError: Error {
    case packageManagerNotInstalled
    case initializationFailed(String)
    case installationFailed(String)
    case invalidConfiguration
}

enum RegistryManagerError: Error {
    case invalidResponse(statusCode: Int)
    case downloadFailed(url: URL, error: Error)
    case maxRetriesExceeded(url: URL, lastError: Error)
    case writeFailed(error: Error)
}

/// Package manager types supported by the system
enum PackageManagerType: String, Codable {
    /// JavaScript
    case npm
    /// Rust
    case cargo
    /// Go
    case golang
    /// Python
    case pip
    /// Ruby
    case gem
    /// C#
    case nuget
    /// OCaml
    case opam
    /// PHP
    case composer
    /// Building from source
    case sourceBuild
    /// Binary download
    case github
}

enum GitReference: Equatable, Codable {
    case tag(String)
    case revision(String)
}

/// Generic package source information that applies to all installation methods.
/// Takes all the necessary information from `RegistryItem`.
struct PackageSource: Equatable, Codable {
    /// The raw source ID string from the registry
    let sourceId: String
    /// The type of the package manager
    let type: PackageManagerType
    /// Package name
    let name: String
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
        name: String,
        version: String,
        repositoryUrl: String? = nil,
        gitReference: GitReference? = nil,
        options: [String: String] = [:]
    ) {
        self.sourceId = sourceId
        self.type = type
        self.name = name
        self.version = version
        self.repositoryUrl = repositoryUrl
        self.gitReference = gitReference
        self.options = options
    }
}

/// Installation method enum with all supported types
enum InstallationMethod: Equatable {
    /// For standard package manager installations
    case standardPackage(source: PackageSource)
    /// For packages that need to be built from source with custom build steps
    case sourceBuild(source: PackageSource, command: String)
    /// For direct binary downloads
    case binaryDownload(source: PackageSource, url: URL)
    /// For installations that aren't recognized
    case unknown

    var packageName: String? {
        switch self {
        case .standardPackage(let source),
             .sourceBuild(let source, _),
             .binaryDownload(let source, _):
            return source.name
        case .unknown:
            return nil
        }
    }

    var packageManagerType: PackageManagerType? {
        switch self {
        case .standardPackage(let source),
             .sourceBuild(let source, _),
             .binaryDownload(let source, _):
            return source.type
        case .unknown:
            return nil
        }
    }
}
