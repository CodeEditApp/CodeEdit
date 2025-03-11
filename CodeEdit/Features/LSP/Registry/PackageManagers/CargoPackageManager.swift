//
//  CargoPackageManager.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/3/25.
//

import Foundation

class CargoPackageManager: PackageManagerProtocol {
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

        let packagePath = installationDirectory.appending(path: source.name)
        print("Installing \(source.name)@\(source.version) in \(packagePath.path)")

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
                cargoArgs.append(contentsOf: ["--version", source.version])
            }

            if let features = source.options["features"] {
                cargoArgs.append(contentsOf: ["--features", features])
            }
            if source.options["locked"] == "true" {
                cargoArgs.append("--locked")
            }
            cargoArgs.append(source.name)

            _ = try await executeInDirectory(in: packagePath.path, cargoArgs)
            print("Successfully installed \(source.name)@\(source.version)")
        } catch {
            print("Installation failed: \(error)")
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
            return output.contains("cargo")
        } catch {
            print("Cargo version check failed: \(error)")
            return false
        }
    }
}
