//
//  PipPackageManager.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/3/25.
//

import Foundation

class PipPackageManager: PackageManagerProtocol {
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

        try createDirectoryStructure(for: packagePath)
        _ = try await executeInDirectory(
            in: packagePath.path, ["python -m venv venv"]
        )

        let requirementsPath = packagePath.appendingPathComponent("requirements.txt")
        if !FileManager.default.fileExists(atPath: requirementsPath.path) {
            try "# Package requirements\n".write(to: requirementsPath, atomically: true, encoding: .utf8)
        }
    }

    func install(method: InstallationMethod) async throws {
        switch method {
        case .standardPackage(let source):
            try await installPythonPackage(source)
        case let .sourceBuild(source, instructions):
            try await buildFromSource(source, instructions)
        case .binaryDownload:
            throw PackageManagerError.invalidConfiguration
        case .unknown:
            throw PackageManagerError.invalidConfiguration
        }
    }

    /// Install a standard Python package using pip
    private func installPythonPackage(_ source: PackageSource) async throws {
        let packagePath = installationDirectory.appending(path: source.name)
        print("Installing \(source.name)@\(source.version) in \(packagePath.path)")

        try await initialize(in: packagePath)

        do {
            let pipCommand = getPipCommand(in: packagePath)

            if let gitRef = source.gitReference, let repoUrl = source.repositoryUrl {
                // Format the git URL based on the reference type
                var gitUrl = "git+\(repoUrl)"
                switch gitRef {
                case .tag(let tag):
                    gitUrl += "@\(tag)"
                case .revision(let rev):
                    gitUrl += "@\(rev)"
                case .branch(let branch):
                    gitUrl += "@\(branch)"
                }
                gitUrl += "#egg=\(source.name)"

                let installArgs = [pipCommand, "install", gitUrl]
                _ = try await executeInDirectory(in: packagePath.path, installArgs)

                try updateRequirements(packagePath: packagePath, gitUrl: gitUrl)
                try await verifyInstallation(packagePath: packagePath, package: source.name)

                print("Successfully installed \(source.name) from git")
            } else {
                var installArgs = [pipCommand, "install"]
                if source.version.lowercased() != "latest" {
                    installArgs.append("\(source.name)==\(source.version)")
                } else {
                    installArgs.append(source.name)
                }

                if let extraIndex = source.options["extra-index-url"] {
                    installArgs.append(contentsOf: ["--extra-index-url", extraIndex])
                }
                if source.options["no-deps"] == "true" {
                    installArgs.append("--no-deps")
                }

                _ = try await executeInDirectory(in: packagePath.path, installArgs)
                try updateRequirements(packagePath: packagePath, package: source.name, version: source.version)
                try await verifyInstallation(packagePath: packagePath, package: source.name)

                print("Successfully installed \(source.name)@\(source.version)")
            }
        } catch {
            print("Installation failed: \(error)")
            throw error
        }
    }

    /// Build a Python package from source
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

                _ = try await executeInDirectory(
                    in: packagePath.path, ["git checkout \(source.version)"]
                )
                let targetInstructions = instructions.first {
                    $0.target == "darwin" || $0.target == "unix"
                } ?? instructions.first

                guard let buildInstructions = targetInstructions else {
                    throw PackageManagerError.invalidConfiguration
                }

                if !FileManager.default.fileExists(atPath: packagePath.appendingPathComponent("venv").path) {
                    _ = try await executeInDirectory(
                        in: packagePath.path, ["python -m venv venv"]
                    )
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

    /// Get the binary path for a Python package
    func getBinaryPath(for package: String) -> String {
        let packagePath = installationDirectory.appending(path: package)
        let customBinPath = packagePath.appending(path: "bin").appending(path: package).path
        if FileManager.default.fileExists(atPath: customBinPath) {
            return customBinPath
        }
        return packagePath.appending(path: "venv").appending(path: "bin").appending(path: package).path
    }

    func isInstalled() async -> Bool {
        let pipCommands = ["pip --version", "pip3 --version", "python -m pip --version"]
        for command in pipCommands {
            do {
                let versionOutput = try await runCommand(command)
                let versionPattern = #"pip \d+\.\d+"#
                let output = versionOutput.reduce(into: "") {
                    $0 += $1.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                if output.range(of: versionPattern, options: .regularExpression) != nil {
                    return true
                }
            } catch {
                continue
            }
        }
        return false
    }

    // MARK: - Helper methods

    private func getPipCommand(in packagePath: URL) -> String {
        let venvPip = "venv/bin/pip"
        return FileManager.default.fileExists(atPath: packagePath.appendingPathComponent(venvPip).path)
            ? venvPip
            : "python -m pip"
    }

    /// Update the requirements.txt file with the installed package
    private func updateRequirements(packagePath: URL, package: String, version: String) throws {
        let requirementsPath = packagePath.appendingPathComponent("requirements.txt")
        var requirementsContent = ""

        if FileManager.default.fileExists(atPath: requirementsPath.path),
           let existingContent = try? String(contentsOf: requirementsPath, encoding: .utf8) {
            requirementsContent = existingContent
        }

        let packageLine = "\(package)==\(version)"
        let packagePattern = "^\\s*\(package)\\s*==.*$"

        if let range = requirementsContent.range(of: packagePattern, options: .regularExpression) {
            // Replace existing version
            requirementsContent.replaceSubrange(range, with: packageLine)
        } else {
            // Add package to requirements
            if !requirementsContent.isEmpty && !requirementsContent.hasSuffix("\n") {
                requirementsContent += "\n"
            }
            requirementsContent += "\(packageLine)\n"
        }

        try requirementsContent.write(to: requirementsPath, atomically: true, encoding: .utf8)
    }

    /// Update the requirements.txt file with a git URL
    private func updateRequirements(packagePath: URL, gitUrl: String) throws {
        let requirementsPath = packagePath.appendingPathComponent("requirements.txt")
        var requirementsContent = ""

        if FileManager.default.fileExists(atPath: requirementsPath.path),
           let existingContent = try? String(contentsOf: requirementsPath, encoding: .utf8) {
            requirementsContent = existingContent
        }

        // Check if git URL is already in requirements
        if !requirementsContent.contains(gitUrl) {
            if !requirementsContent.isEmpty && !requirementsContent.hasSuffix("\n") {
                requirementsContent += "\n"
            }
            requirementsContent += "\(gitUrl)\n"
        }

        try requirementsContent.write(to: requirementsPath, atomically: true, encoding: .utf8)
    }

    private func verifyInstallation(packagePath: URL, package: String) async throws {
        let pipCommand = getPipCommand(in: packagePath)
        let output = try await executeInDirectory(
            in: packagePath.path, ["\(pipCommand) list"]
        )

        // Check if the package appears in pip list
        let packagePattern = "^\(package)\\s+.*$"
        let packageFound = output.contains { line in
            line.range(of: packagePattern, options: .regularExpression) != nil
        }

        guard packageFound else {
            throw PackageManagerError.installationFailed("Package \(package) not found in pip list")
        }
    }
}
