//
//  PackageManagerFactory.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/3/25.
//

import Foundation

/// Factory for creating the appropriate package manager based on installation method
final class PackageManagerFactory {
    let installationDirectory: URL

    init(installationDirectory: URL) {
        self.installationDirectory = installationDirectory
    }

    /// Create the appropriate package manager for the given installation method
    func createPackageManager(for method: InstallationMethod) -> PackageManagerProtocol? {
        switch method.packageManagerType {
        case .npm:
            return NPMPackageManager(installationDirectory: installationDirectory)
        case .cargo:
            return CargoPackageManager(installationDirectory: installationDirectory)
        case .pip:
            return PipPackageManager(installationDirectory: installationDirectory)
        case .golang:
            return GolangPackageManager(installationDirectory: installationDirectory)
        case .nuget, .opam, .customBuild, .gem:
            // TODO: IMPLEMENT OTHER PACKAGE MANAGERS
            return nil
        case .github:
            return createPackageManagerFromGithub(for: method)
        case .none:
            return nil
        }
    }

    /// Parse a registry entry and create the appropriate installation method
    static func parseRegistryEntry(_ entry: [String: Any]) -> InstallationMethod? {
        guard let source = entry["source"] as? [String: Any],
              let sourceId = source["id"] as? String else {
            return nil
        }

        let buildInstructions = source["build"] as? [[String: Any]]

        // Detect the build tool from the registry entry
        var buildTool: String?
        if let bin = entry["bin"] as? [String: String] {
            let binValues = Array(bin.values)
            if !binValues.isEmpty {
                let value = binValues[0]
                if value.hasPrefix("cargo:") {
                    buildTool = "cargo"
                } else if value.hasPrefix("npm:") {
                    buildTool = "npm"
                } else if value.hasPrefix("pypi:") {
                    buildTool = "pip"
                } else if value.hasPrefix("gem:") {
                    buildTool = "gem"
                } else if value.hasPrefix("golang:") {
                    buildTool = "golang"
                }
            }
        }

        var method = PackageSourceParser.parse(sourceId, buildInstructions: buildInstructions)

        if let buildTool = buildTool {
            switch method {
            case .standardPackage(var source):
                var options = source.options
                options["buildTool"] = buildTool
                source = PackageSource(
                    sourceId: source.sourceId,
                    type: source.type,
                    name: source.name,
                    version: source.version,
                    subpath: source.subpath,
                    repositoryUrl: source.repositoryUrl,
                    gitReference: source.gitReference,
                    options: options
                )
                method = .standardPackage(source: source)
            case .sourceBuild(var source, let instructions):
                var options = source.options
                options["buildTool"] = buildTool
                source = PackageSource(
                    sourceId: source.sourceId,
                    type: source.type,
                    name: source.name,
                    version: source.version,
                    subpath: source.subpath,
                    repositoryUrl: source.repositoryUrl,
                    gitReference: source.gitReference,
                    options: options
                )
                method = .sourceBuild(source: source, buildInstructions: instructions)
            case .binaryDownload(var source, let url):
                var options = source.options
                options["buildTool"] = buildTool
                source = PackageSource(
                    sourceId: source.sourceId,
                    type: source.type,
                    name: source.name,
                    version: source.version,
                    subpath: source.subpath,
                    repositoryUrl: source.repositoryUrl,
                    gitReference: source.gitReference,
                    options: options
                )
                method = .binaryDownload(source: source, url: url)
            case .unknown:
                break
            }
        }
        return method
    }

    /// Install a package from a registry entry
    func installFromRegistryEntry(_ entry: [String: Any]) async throws {
        guard let method = PackageManagerFactory.parseRegistryEntry(entry),
              let manager = createPackageManager(for: method) else {
            throw PackageManagerError.invalidConfiguration
        }
        try await manager.install(method: method)
    }

    /// Install a package from a source ID string
    func installFromSourceID(_ sourceID: String) async throws {
        let method = PackageSourceParser.parse(sourceID)
        guard let manager = createPackageManager(for: method) else {
            throw PackageManagerError.packageManagerNotInstalled
        }
        try await manager.install(method: method)
    }

    private func createPackageManagerFromGithub(for method: InstallationMethod) -> PackageManagerProtocol? {
        if case let .sourceBuild(source, instructions) = method {
            if let buildTool = source.options["buildTool"] {
                switch buildTool {
                case "cargo": return CargoPackageManager(installationDirectory: installationDirectory)
                case "npm": return NPMPackageManager(installationDirectory: installationDirectory)
                case "pip": return PipPackageManager(installationDirectory: installationDirectory)
                case "golang": return GolangPackageManager(installationDirectory: installationDirectory)
                default: break
                }
            }

            // If no buildTool option, try to determine from build instructions
            for instruction in instructions {
                for command in instruction.commands {
                    if command.contains("cargo ") {
                        return CargoPackageManager(installationDirectory: installationDirectory)
                    } else if command.contains("npm ") {
                        return NPMPackageManager(installationDirectory: installationDirectory)
                    } else if command.contains("pip ") || command.contains("python ") {
                        return PipPackageManager(installationDirectory: installationDirectory)
                    } else if command.contains("go ") {
                        return GolangPackageManager(installationDirectory: installationDirectory)
                    }
                }
            }

            // Check the binary path for clues if needed
            let binPath = instructions.first?.binaryPath ?? ""
            if binPath.contains("target/release") || binPath.hasSuffix(".rs") {
                return CargoPackageManager(installationDirectory: installationDirectory)
            } else if binPath.contains("node_modules") {
                return NPMPackageManager(installationDirectory: installationDirectory)
            } else if binPath.contains(".py") {
                return PipPackageManager(installationDirectory: installationDirectory)
            } else if binPath.hasSuffix(".go") || binPath.contains("/go/bin") {
                return GolangPackageManager(installationDirectory: installationDirectory)
            }
        }

        // Default to cargo
        return CargoPackageManager(installationDirectory: installationDirectory)
    }
}
