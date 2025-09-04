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

    // MARK: - PackageManagerProtocol

    func install(method installationMethod: InstallationMethod) throws -> [PackageManagerInstallStep] {
        guard case .standardPackage(let source) = installationMethod else {
            throw PackageManagerError.invalidConfiguration
        }

        let packagePath = installationDirectory.appending(path: source.entryName)
        return [
            initialize(in: packagePath),
            runPipInstall(source, in: packagePath),
            updateRequirements(in: packagePath),
            verifyInstallation(source, in: packagePath)
        ]
    }

    func isInstalled(method installationMethod: InstallationMethod) -> PackageManagerInstallStep {
        PackageManagerInstallStep(name: "", confirmation: .none) { model in
            let pipCommands = ["pip3 --version", "python3 -m pip --version"]
            var didFindPip = false
            for command in pipCommands {
                do {
                    let versionOutput = try await model.runCommand(command)
                    let versionPattern = #"pip \d+\.\d+"#
                    let output = versionOutput.reduce(into: "") {
                        $0 += $1.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    if output.range(of: versionPattern, options: .regularExpression) != nil {
                        didFindPip = true
                        break
                    }
                } catch {
                    continue
                }
            }
            guard didFindPip else {
                throw PackageManagerError.packageManagerNotInstalled
            }
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

    // MARK: - Initialize

    func initialize(in packagePath: URL) -> PackageManagerInstallStep {
        PackageManagerInstallStep(name: "Initialize Directory Structure", confirmation: .none) { model in
            try await model.createDirectoryStructure(for: packagePath)
            try await model.executeInDirectory(in: packagePath.path(percentEncoded: false), ["python -m venv venv"])

            let requirementsPath = packagePath.appending(path: "requirements.txt")
            if !FileManager.default.fileExists(atPath: requirementsPath.path) {
                try "# Package requirements\n".write(to: requirementsPath, atomically: true, encoding: .utf8)
            }
        }
    }

    // MARK: - Pip Install

    func runPipInstall(_ source: PackageSource, in packagePath: URL) -> PackageManagerInstallStep {
        let pipCommand = getPipCommand(in: packagePath)
        return PackageManagerInstallStep(
            name: "Install Package Using pip",
            confirmation: .required(
                message: "This requires the pip package \(source.pkgName)."
                + "\nAllow CodeEdit to install this package?"
            )
        ) { model in
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

            try await model.executeInDirectory(in: packagePath.path, installArgs)
        }
    }

    // MARK: - Update Requirements.txt

    /// Update the requirements.txt file with the installed package and extras
    private func updateRequirements(in packagePath: URL) -> PackageManagerInstallStep {
        let pipCommand = getPipCommand(in: packagePath)
        return PackageManagerInstallStep(
            name: "Update requirements.txt",
            confirmation: .none
        ) { model in
            let requirementsPath = packagePath.appending(path: "requirements.txt")

            let freezeOutput = try await model.executeInDirectory(
                in: packagePath.path(percentEncoded: false),
                ["\(pipCommand)", "freeze"]
            )

            await model.status("Writing requirements to requirements.txt")
            let requirementsContent = freezeOutput.joined(separator: "\n") + "\n"
            try requirementsContent.write(to: requirementsPath, atomically: true, encoding: .utf8)
        }
    }

    // MARK: - Verify Installation

    private func verifyInstallation(_ source: PackageSource, in packagePath: URL) -> PackageManagerInstallStep {
        let pipCommand = getPipCommand(in: packagePath)
        return PackageManagerInstallStep(
            name: "Verify Installation",
            confirmation: .none
        ) { model in
            let output = try await model.executeInDirectory(
                in: packagePath.path(percentEncoded: false),
                ["\(pipCommand)", "list", "--format=freeze"]
            )

            // Normalize package names for comparison
            let normalizedPackageHyphen = source.pkgName.replacingOccurrences(of: "_", with: "-").lowercased()
            let normalizedPackageUnderscore = source.pkgName.replacingOccurrences(of: "-", with: "_").lowercased()

            // Check if the package name appears in requirements.txt
            let installedPackages = output.map { line in
                line.lowercased().split(separator: "=").first?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            let packageFound = installedPackages.contains { installedPackage in
                installedPackage == normalizedPackageHyphen || installedPackage == normalizedPackageUnderscore
            }

            guard packageFound else {
                throw PackageManagerError.installationFailed("Package \(source.pkgName) not found in pip list")
            }
        }
    }

    private func getPipCommand(in packagePath: URL) -> String {
        let venvPip = "venv/bin/pip"
        return FileManager.default.fileExists(atPath: packagePath.appending(path: venvPip).path)
        ? venvPip
        : "python3 -m pip"
    }
}
