//
//  GolangPackageManager.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/3/25.
//

import Foundation

class GolangPackageManager: PackageManagerProtocol {
    private let installationDirectory: URL
    internal let shellClient: ShellClient

    init(installationDirectory: URL) {
        self.installationDirectory = installationDirectory
        self.shellClient = .live()
    }

    func initialize(in packagePath: URL) async throws {
        guard await isInstalled() else {
            throw PackageManagerError.packageManagerNotInstalled
        }

        do {
            try createDirectoryStructure(for: packagePath)

            // For Go, we need to set up a proper module structure
            let goModPath = packagePath.appendingPathComponent("go.mod")
            if !FileManager.default.fileExists(atPath: goModPath.path) {
                let moduleName = "codeedit.temp/placeholder"
                _ = try await executeInDirectory(
                    in: packagePath.path, ["go mod init \(moduleName)"]
                )
            }
        } catch {
            throw PackageManagerError.initializationFailed(error.localizedDescription)
        }
    }

    func install(method: InstallationMethod) async throws {
        guard case .standardPackage(let source) = method else {
            throw PackageManagerError.invalidConfiguration
        }

        let packagePath = installationDirectory.appending(path: source.name)
        print("Installing Go package \(source.name)@\(source.version) in \(packagePath.path)")

        try await initialize(in: packagePath)

        do {
            if let gitRef = source.gitReference, let repoUrl = source.repositoryUrl {
                // Check if this is a Git-based package
                var packageName = source.name
                if !packageName.contains("github.com") && !packageName.contains("golang.org") {
                    packageName = repoUrl.replacingOccurrences(of: "https://", with: "")
                }

                var gitVersion: String
                switch gitRef {
                case .tag(let tag):
                    gitVersion = tag
                case .revision(let rev):
                    gitVersion = rev
                }

                let versionedPackage = "\(packageName)@\(gitVersion)"
                _ = try await executeInDirectory(
                    in: packagePath.path, ["go get \(versionedPackage)"]
                )
            } else {
                // Standard package installation
                let versionedPackage = "\(source.name)@\(source.version)"
                _ = try await executeInDirectory(
                    in: packagePath.path, ["go get \(versionedPackage)"]
                )
            }

            // If there's a subpath, build the binary
            if let subpath = source.options["subpath"] {
                let binPath = packagePath.appendingPathComponent("bin")
                if !FileManager.default.fileExists(atPath: binPath.path) {
                    try FileManager.default.createDirectory(at: binPath, withIntermediateDirectories: true)
                }

                let binaryName = subpath.components(separatedBy: "/").last ??
                    source.name.components(separatedBy: "/").last ?? source.name
                let buildArgs = ["go", "build", "-o", "bin/\(binaryName)"]

                // If source.name includes the full import path (like github.com/owner/repo)
                if source.name.contains("/") {
                    _ = try await executeInDirectory(
                        in: packagePath.path, buildArgs + ["\(source.name)/\(subpath)"]
                    )
                } else {
                    _ = try await executeInDirectory(
                        in: packagePath.path, buildArgs + [subpath]
                    )
                }
                let execPath = packagePath.appending(path: "bin").appending(path: binaryName).path
                _ = try await runCommand("chmod +x \"\(execPath)\"")
            }

            print("Successfully installed \(source.name)@\(source.version)")
        } catch {
            print("Installation failed: \(error)")
            try? cleanupFailedInstallation(packagePath: packagePath)
            throw PackageManagerError.installationFailed(error.localizedDescription)
        }
    }

    /// Get the binary path for a Go package
    func getBinaryPath(for package: String) -> String {
        let binPath = installationDirectory.appending(path: package).appending(path: "bin")
        let binaryName = package.components(separatedBy: "/").last ?? package
        let specificBinPath = binPath.appendingPathComponent(binaryName).path
        if FileManager.default.fileExists(atPath: specificBinPath) {
            return specificBinPath
        }
        return binPath.path
    }

    /// Check if go is installed
    func isInstalled() async -> Bool {
        do {
            let versionOutput = try await runCommand("go version")
            let versionPattern = #"go version go\d+\.\d+"#
            let output = versionOutput.reduce(into: "") {
                $0 += $1.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return output.range(of: versionPattern, options: .regularExpression) != nil
        } catch {
            print("Go version check failed: \(error)")
            return false
        }
    }

    // MARK: - Helper methods

    /// Clean up after a failed installation
    private func cleanupFailedInstallation(packagePath: URL) throws {
        let goSumPath = packagePath.appendingPathComponent("go.sum")
        if FileManager.default.fileExists(atPath: goSumPath.path) {
            try FileManager.default.removeItem(at: goSumPath)
        }
    }

    /// Verify the go.mod file has the expected dependencies
    private func verifyGoModDependencies(packagePath: URL, dependencyPath: String) async throws -> Bool {
        let output = try await executeInDirectory(
            in: packagePath.path, ["go list -m all"]
        )

        // Check if the dependency appears in the module list
        return output.contains { line in
            line.contains(dependencyPath)
        }
    }
}
