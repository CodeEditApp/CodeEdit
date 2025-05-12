//
//  PipPackageManager.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/3/25.
//

import Foundation

final class PipPackageManager: PackageManagerProtocol {
    private let installationDirectory: URL

    let shellClient: ShellClient

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

            let requirementsPath = packagePath.appending(path: "requirements.txt")
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

        let packagePath = installationDirectory.appending(path: source.entryName)
        try await initialize(in: packagePath)

        do {
            let pipCommand = getPipCommand(in: packagePath)
            var installArgs = [pipCommand, "install"]

            if source.version.lowercased() != "latest" {
                installArgs.append("\(source.pkgName)==\(source.version)")
            } else {
                installArgs.append(source.pkgName)
            }

            let extras = source.options["extra"]
            if let extras {
                if let lastIndex = installArgs.indices.last {
                    installArgs[lastIndex] += "[\(extras)]"
                }
            }

            _ = try await executeInDirectory(in: packagePath.path, installArgs)
            try await updateRequirements(packagePath: packagePath)
            try await verifyInstallation(packagePath: packagePath, package: source.pkgName)
        } catch {
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
        let pipCommands = ["pip3 --version", "python3 -m pip --version"]
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
        return FileManager.default.fileExists(atPath: packagePath.appending(path: venvPip).path)
            ? venvPip
            : "python -m pip"
    }

    /// Update the requirements.txt file with the installed package and extras
    private func updateRequirements(packagePath: URL) async throws {
        let pipCommand = getPipCommand(in: packagePath)
        let requirementsPath = packagePath.appending(path: "requirements.txt")

        let freezeOutput = try await executeInDirectory(
            in: packagePath.path,
            ["\(pipCommand)", "freeze"]
        )

        let requirementsContent = freezeOutput.joined(separator: "\n") + "\n"
        try requirementsContent.write(to: requirementsPath, atomically: true, encoding: .utf8)
    }

    private func verifyInstallation(packagePath: URL, package: String) async throws {
        let pipCommand = getPipCommand(in: packagePath)
        let output = try await executeInDirectory(
            in: packagePath.path, ["\(pipCommand)", "list", "--format=freeze"]
        )

        // Normalize package names for comparison
        let normalizedPackageHyphen = package.replacingOccurrences(of: "_", with: "-").lowercased()
        let normalizedPackageUnderscore = package.replacingOccurrences(of: "-", with: "_").lowercased()

        // Check if the package name appears in requirements.txt
        let installedPackages = output.map { line in
            line.lowercased().split(separator: "=").first?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let packageFound = installedPackages.contains { installedPackage in
            installedPackage == normalizedPackageHyphen || installedPackage == normalizedPackageUnderscore
        }

        guard packageFound else {
            throw PackageManagerError.installationFailed("Package \(package) not found in pip list")
        }
    }
}
