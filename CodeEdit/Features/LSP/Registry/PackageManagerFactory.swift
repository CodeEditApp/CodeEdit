//
//  PackageManagerFactory.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/3/25.
//

import Foundation

/// Factory for creating the appropriate package manager based on installation method
final class PackageManagerFactory {
    private let installationDirectory: URL

    init(installationDirectory: URL) {
        self.installationDirectory = installationDirectory
    }

    /// Install a package from a registry entry
    func installFromRegistryEntry(_ entry: RegistryItem) async throws {
        guard let method = Self.parseRegistryEntry(entry),
              let manager = createPackageManager(for: method) else {
            throw PackageManagerError.invalidConfiguration
        }
        try await manager.install(method: method)
    }

    /// Parse a registry entry and create the appropriate installation method
    private static func parseRegistryEntry(_ entry: RegistryItem) -> InstallationMethod? {
        let sourceId = entry.source.id
        if sourceId.hasPrefix("pkg:cargo/") {
            return PackageSourceParser.parseCargoPackage(entry)
        } else if sourceId.hasPrefix("pkg:npm/") {
            return PackageSourceParser.parseNpmPackage(entry)
        } else if sourceId.hasPrefix("pkg:pypi/") {
            return PackageSourceParser.parsePythonPackage(entry)
        } else if sourceId.hasPrefix("pkg:gem/") {
            return PackageSourceParser.parseRubyGem(entry)
        } else if sourceId.hasPrefix("pkg:golang/") {
            return PackageSourceParser.parseGolangPackage(entry)
        } else if sourceId.hasPrefix("pkg:github/") {
            return PackageSourceParser.parseGithubPackage(entry)
        } else {
            return .unknown
        }
    }

    /// Create the appropriate package manager for the given installation method
    private func createPackageManager(for method: InstallationMethod) -> PackageManagerProtocol? {
        switch method.packageManagerType {
        case .npm:
            return NPMPackageManager(installationDirectory: installationDirectory)
        case .cargo:
            return CargoPackageManager(installationDirectory: installationDirectory)
        case .pip:
            return PipPackageManager(installationDirectory: installationDirectory)
        case .golang:
            return GolangPackageManager(installationDirectory: installationDirectory)
        case .github, .sourceBuild:
            return GithubPackageManager(installationDirectory: installationDirectory)
        case .nuget, .opam, .gem, .composer:
            // TODO: IMPLEMENT OTHER PACKAGE MANAGERS
            return nil
        case .none:
            return nil
        }
    }
}
