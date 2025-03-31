//
//  CargoPackageManager.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/3/25.
//

import Foundation

final class CargoPackageManager: PackageManagerProtocol {
    private let installationDirectory: URL

    internal let shellClient: ShellClient

    init(installationDirectory: URL) {
        self.installationDirectory = installationDirectory
        self.shellClient = .live()
    }

    func initialize(in packagePath: URL) async throws {
        do {
            try createDirectoryStructure(for: packagePath)
        } catch {
            throw PackageManagerError.initializationFailed(error.localizedDescription)
        }

        guard await isInstalled() else {
            throw PackageManagerError.packageManagerNotInstalled
        }
    }

    func install(method: InstallationMethod) async throws {
        guard case .standardPackage(let source) = method else {
            throw PackageManagerError.invalidConfiguration
        }

        let packagePath = installationDirectory.appending(path: source.entryName)
        try await initialize(in: packagePath)

        do {
            var cargoArgs = ["cargo", "install", "--root", "."]

            // If this is a git-based package
            if let gitRef = source.gitReference, let repoUrl = source.repositoryUrl {
                cargoArgs.append(contentsOf: ["--git", repoUrl])
                switch gitRef {
                case .tag(let tag):
                    cargoArgs.append(contentsOf: ["--tag", tag])
                case .revision(let rev):
                    cargoArgs.append(contentsOf: ["--rev", rev])
                }
            } else {
                cargoArgs.append("\(source.pkgName)@\(source.version)")
            }

            if let features = source.options["features"] {
                cargoArgs.append(contentsOf: ["--features", features])
            }
            if source.options["locked"] == "true" {
                cargoArgs.append("--locked")
            }

            _ = try await executeInDirectory(in: packagePath.path, cargoArgs)
        } catch {
            throw error
        }
    }

    func getBinaryPath(for package: String) -> String {
        return installationDirectory.appending(path: package).appending(path: "bin").path
    }

    func isInstalled() async -> Bool {
        do {
            let versionOutput = try await runCommand("cargo --version")
            let output = versionOutput.reduce(into: "") {
                $0 += $1.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return output.starts(with: "cargo")
        } catch {
            return false
        }
    }
}
