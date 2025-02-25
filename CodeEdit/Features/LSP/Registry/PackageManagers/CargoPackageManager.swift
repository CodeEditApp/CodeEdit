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
        try createDirectoryStructure(for: packagePath)

        guard await isInstalled() else {
            throw PackageManagerError.packageManagerNotInstalled
        }
    }

    /// Install a package using the new installation method
    func install(method: InstallationMethod) async throws {
        switch method {
        case .standardPackage(let source):
            try await installCargoPackage(source)
        case let .sourceBuild(source, instructions):
            try await buildFromSource(source, instructions)
        case .binaryDownload:
            throw PackageManagerError.invalidConfiguration
        case .unknown:
            throw PackageManagerError.invalidConfiguration
        }
    }

    /// Install a standard cargo package
    private func installCargoPackage(_ source: PackageSource) async throws {
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
                case .branch(let branch):
                    cargoArgs.append(contentsOf: ["--branch", branch])
                }
            } else {
                // Standard version-based install
                cargoArgs.append(contentsOf: ["--version", source.version])
            }

            if let features = source.options["features"] {
                cargoArgs.append(contentsOf: ["--features", features])
            }
            if source.options["locked"] == "true" {
                cargoArgs.append("--locked")
            }

            cargoArgs.append(source.name)
            let output = try await executeInDirectory(in: packagePath.path, cargoArgs)
            print("Successfully installed \(source.name)@\(source.version)")
        } catch {
            print("Installation failed: \(error)")
            throw error
        }
    }

    /// Build a package from source
    private func buildFromSource(_ source: PackageSource, _ instructions: [BuildInstructions]) async throws {
        let packagePath = installationDirectory.appending(path: source.name)
        print("Building \(source.name) from source in \(packagePath.path)")

        do {
            if let repoUrl = source.repositoryUrl {
                try createDirectoryStructure(for: packagePath)

                if FileManager.default.fileExists(atPath: packagePath.appendingPathComponent(".git").path) {
                    _ = try await executeInDirectory(
                        in: packagePath.path, ["git fetch --all"]
                    )
                } else {
                    _ = try await executeInDirectory(
                        in: packagePath.path, ["git clone \(repoUrl) ."]
                    )
                }

                // Checkout the specific version
                _ = try await executeInDirectory(
                    in: packagePath.path, ["git checkout \(source.version)"]
                )

                // Find the relevant build instruction for this platform
                let targetInstructions = instructions.first {
                    $0.target == "darwin" || $0.target == "unix"
                } ?? instructions.first

                guard let buildInstructions = targetInstructions else {
                    throw PackageManagerError.invalidConfiguration
                }

                // Execute each build command
                for command in buildInstructions.commands {
                    _ = try await executeInDirectory(in: packagePath.path, [command])
                }

                // Create bin directory if it doesn't exist
                let binPath = packagePath.appendingPathComponent("bin")
                if !FileManager.default.fileExists(atPath: binPath.path) {
                    try FileManager.default.createDirectory(at: binPath, withIntermediateDirectories: true)
                }

                // Copy the built binary to the bin directory if it's not already there
                let builtBinaryPath = packagePath.appendingPathComponent(buildInstructions.binaryPath)
                let targetBinaryPath = binPath.appendingPathComponent(source.name)

                if builtBinaryPath.path != targetBinaryPath.path &&
                   FileManager.default.fileExists(atPath: builtBinaryPath.path) {
                    try FileManager.default.copyItem(at: builtBinaryPath, to: targetBinaryPath)
                    // Make the binary executable
                    _ = try await runCommand("chmod +x \"\(targetBinaryPath.path)\"")
                }

                print("Successfully built \(source.name) from source")
            } else {
                throw PackageManagerError.invalidConfiguration
            }
        } catch {
            print("Build failed: \(error)")
            throw error
        }
    }

    func getBinaryPath(for package: String) -> String {
        return installationDirectory.appending(path: package).appending(path: "bin").path
    }

    func isInstalled() async -> Bool {
        do {
            let versionOutput = try await runCommand("cargo --version")
            // Check for cargo version output
            let output = versionOutput.reduce(into: "") {
                $0 += $1.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return output.contains("cargo")
        } catch {
            print("Cargo version check failed: \(error)")
            return false
        }
    }

    internal func executeInDirectory(in packagePath: String, _ args: [String]) async throws -> [String] {
        let escapedArgs = args.map { arg in
            return arg.contains(" ") ? "\"\(arg)\"" : arg
        }.joined(separator: " ")
        let command = "cd \"\(packagePath)\" && \(escapedArgs)"
        return try await runCommand(command)
    }
}
