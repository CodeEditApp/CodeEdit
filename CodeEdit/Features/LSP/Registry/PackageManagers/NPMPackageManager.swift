//
//  NPMPackageManager.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/2/25.
//

import Foundation

class NPMPackageManager: PackageManagerProtocol {
    private let installationDirectory: URL

    internal let shellClient: ShellClient

    init(installationDirectory: URL) {
        self.installationDirectory = installationDirectory
        self.shellClient = .live()
    }

    /// Initializes the npm project if not already initialized
    func initialize(in packagePath: URL) async throws {
        guard await isInstalled() else {
            throw PackageManagerError.packageManagerNotInstalled
        }

        // Clean existing files
        let pkgJson = packagePath.appending(path: "package.json")
        if FileManager.default.fileExists(atPath: pkgJson.path) {
            try FileManager.default.removeItem(at: pkgJson)
        }
        let pkgLockJson = packagePath.appending(path: "package-lock.json")
        if FileManager.default.fileExists(atPath: pkgLockJson.path) {
            try FileManager.default.removeItem(at: pkgLockJson)
        }

        // Init npm directory with .npmrc file
        try createDirectoryStructure(for: packagePath)
        _ = try await executeInDirectory(
            in: packagePath.path, ["npm init --yes --scope=codeedit"]
        )

        let npmrcPath = packagePath.appendingPathComponent(".npmrc")
        if !FileManager.default.fileExists(atPath: npmrcPath.path) {
            try "install-strategy=shallow".write(to: npmrcPath, atomically: true, encoding: .utf8)
        }
    }

    /// Install a package using the new installation method
    func install(method: InstallationMethod) async throws {
        switch method {
        case .standardPackage(let source):
            try await installNpmPackage(source)
        case let .sourceBuild(source, instructions):
            try await buildFromSource(source, instructions)
        case .binaryDownload:
            throw PackageManagerError.invalidConfiguration
        case .unknown:
            throw PackageManagerError.invalidConfiguration
        }
    }

    /// Install a standard npm package
    private func installNpmPackage(_ source: PackageSource) async throws {
        let packagePath = installationDirectory.appending(path: source.name)
        print("Installing \(source.name)@\(source.version) in \(packagePath.path)")

        try await initialize(in: packagePath)

        do {
            // Determine if this is a git-based package
            if let gitRef = source.gitReference, let repoUrl = source.repositoryUrl {
                // Format the git URL based on the reference type
                var gitUrl = repoUrl
                switch gitRef {
                case .tag(let tag):
                    gitUrl += "#tag=\(tag)"
                case .revision(let rev):
                    gitUrl += "#\(rev)"
                case .branch(let branch):
                    gitUrl += "#\(branch)"
                }

                let installArgs = ["npm", "install", gitUrl]
                _ = try await executeInDirectory(in: packagePath.path, installArgs)

                print("Successfully installed \(source.name) from git")
            } else {
                var installArgs = ["npm", "install", "\(source.name)@\(source.version)"]
                if let dev = source.options["dev"], dev.lowercased() == "true" {
                    installArgs.append("--save-dev")
                }
                if let extraPackages = source.options["extraPackages"]?.split(separator: ",") {
                    for pkg in extraPackages {
                        installArgs.append(String(pkg).trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }

                _ = try await executeInDirectory(in: packagePath.path, installArgs)
                try verifyInstallation(package: source.name, version: source.version)

                print("Successfully installed \(source.name)@\(source.version)")
            }
        } catch {
            print("Installation failed: \(error)")
            let nodeModulesPath = packagePath.appendingPathComponent("node_modules").path
            try? FileManager.default.removeItem(atPath: nodeModulesPath)
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

                _ = try await executeInDirectory(
                    in: packagePath.path, ["git checkout \(source.version)"]
                )
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

    /// Get the path to the binary
    func getBinaryPath(for package: String) -> String {
        let binDirectory = installationDirectory
            .appending(path: package)
            .appending(path: "node_modules")
            .appending(path: ".bin")
        return binDirectory.appendingPathComponent(package).path
    }

    /// Checks if npm is installed
    func isInstalled() async -> Bool {
        do {
            let versionOutput = try await runCommand("npm --version")
            let versionPattern = #"^\d+\.\d+\.\d+$"#
            let output = versionOutput.reduce(into: "") {
                $0 += $1.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return output.range(of: versionPattern, options: .regularExpression) != nil
        } catch {
            return false
        }
    }

    /// Verify the installation was successful
    private func verifyInstallation(package: String, version: String) throws {
        let packagePath = installationDirectory.appending(path: package)
        let packageJsonPath = packagePath.appendingPathComponent("package.json").path

        // Verify package.json contains the installed package
        guard let packageJsonData = FileManager.default.contents(atPath: packageJsonPath),
              let packageJson = try? JSONSerialization.jsonObject(with: packageJsonData, options: []),
              let packageDict = packageJson as? [String: Any],
              let dependencies = packageDict["dependencies"] as? [String: String],
              let installedVersion = dependencies[package] else {
            throw PackageManagerError.installationFailed("Package not found in package.json")
        }

        // Verify installed version matches requested version
        let normalizedInstalledVersion = installedVersion.trimmingCharacters(in: CharacterSet(charactersIn: "^~"))
        let normalizedRequestedVersion = version.trimmingCharacters(in: CharacterSet(charactersIn: "^~"))
        if normalizedInstalledVersion != normalizedRequestedVersion &&
           !installedVersion.contains(normalizedRequestedVersion) {
            throw PackageManagerError.installationFailed(
                "Version mismatch: Expected \(version), but found \(installedVersion)"
            )
        }

        // Verify the package exists in node_modules
        let packageDirectory = packagePath
            .appendingPathComponent("node_modules")
            .appendingPathComponent(package)
        guard FileManager.default.fileExists(atPath: packageDirectory.path) else {
            throw PackageManagerError.installationFailed("Package not found in node_modules")
        }
    }
}
