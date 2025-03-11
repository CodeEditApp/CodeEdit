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

        do {
            try createDirectoryStructure(for: packagePath)
            _ = try await executeInDirectory(
                in: packagePath.path, ["python -m venv venv"]
            )

            let requirementsPath = packagePath.appendingPathComponent("requirements.txt")
            if !FileManager.default.fileExists(atPath: requirementsPath.path) {
                try "# Package requirements\n".write(to: requirementsPath, atomically: true, encoding: .utf8)
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
        print("Installing \(source.name)@\(source.version) in \(packagePath.path)")

        try await initialize(in: packagePath)

        do {
            let pipCommand = getPipCommand(in: packagePath)
            var installArgs = [pipCommand, "install"]

            if source.version.lowercased() != "latest" {
                installArgs.append("\(source.name)==\(source.version)")
            } else {
                installArgs.append(source.name)
            }

            let extras = source.options["extra"]
            if let extras = extras {
                if let lastIndex = installArgs.indices.last {
                    installArgs[lastIndex] += "[\(extras)]"
                }
            }

            _ = try await executeInDirectory(in: packagePath.path, installArgs)
            try updateRequirements(
                packagePath: packagePath,
                package: source.name,
                version: source.version,
                extras: extras
            )
            try await verifyInstallation(packagePath: packagePath, package: source.name)

            print("Successfully installed \(source.name)@\(source.version)")
        } catch {
            print("Installation failed: \(error)")
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

    /// Update the requirements.txt file with the installed package and extras
    private func updateRequirements(packagePath: URL, package: String, version: String, extras: String? = nil) throws {
        let requirementsPath = packagePath.appendingPathComponent("requirements.txt")
        var requirementsContent = ""

        if FileManager.default.fileExists(atPath: requirementsPath.path),
           let existingContent = try? String(contentsOf: requirementsPath, encoding: .utf8) {
            requirementsContent = existingContent
        }

        var packageLine = "\(package)"
        if let extras = extras {
            packageLine += "[\(extras)]"
        }
        packageLine += "==\(version)"

        let packagePattern = "^\\s*\(package)(\\[.*\\])?\\s*==.*$"
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
