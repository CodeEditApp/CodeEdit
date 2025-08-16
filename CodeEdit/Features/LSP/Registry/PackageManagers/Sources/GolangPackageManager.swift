//
//  GolangPackageManager.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/3/25.
//

import Foundation

final class GolangPackageManager: PackageManagerProtocol {
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
        var steps = [
            initialize(in: packagePath),
            runGoInstall(source, packagePath: packagePath)
        ]

        if source.options["subpath"] != nil {
            steps.append(buildBinary(source, packagePath: packagePath))
        }

        return steps
    }

    /// Check if go is installed
    func isInstalled(method installationMethod: InstallationMethod) -> PackageManagerInstallStep {
        PackageManagerInstallStep(
            name: "",
            confirmation: .required(message: "This package requires go to install. Allow CodeEdit to run go commands?")
        ) { model in
            let versionOutput = try await model.runCommand("go version")
            let versionPattern = #"go version go\d+\.\d+"#
            let output = versionOutput.reduce(into: "") {
                $0 += $1.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            guard output.range(of: versionPattern, options: .regularExpression) != nil else {
                throw PackageManagerError.packageManagerNotInstalled
            }
        }
    }

    /// Get the binary path for a Go package
    func getBinaryPath(for package: String) -> String {
        let binPath = installationDirectory.appending(path: package).appending(path: "bin")
        let binaryName = package.components(separatedBy: "/").last ?? package
        let specificBinPath = binPath.appending(path: binaryName).path
        if FileManager.default.fileExists(atPath: specificBinPath) {
            return specificBinPath
        }
        return binPath.path
    }

    // MARK: - Initialize

    func initialize(in packagePath: URL) -> PackageManagerInstallStep {
        PackageManagerInstallStep(
            name: "Initialize Directory Structure",
            confirmation: .none
        ) { model in
            try await model.createDirectoryStructure(for: packagePath)

            // For Go, we need to set up a proper module structure
            let goModPath = packagePath.appending(path: "go.mod")
            if !FileManager.default.fileExists(atPath: goModPath.path) {
                let moduleName = "codeedit.temp/placeholder"
                _ = try await model.executeInDirectory(
                    in: packagePath.path, ["go mod init \(moduleName)"]
                )
            }
        }
    }

    // MARK: - Install Using Go

    func runGoInstall(_ source: PackageSource, packagePath: URL) -> PackageManagerInstallStep {
        let installCommand = getGoInstallCommand(source)
        return PackageManagerInstallStep(
            name: "Install Package Using go",
            confirmation: .required(
                message: "This requires installing the go package \(installCommand)."
                + "\nAllow CodeEdit to install this package?"
            )
        ) { model in
            let gobinPath = packagePath.appending(path: "bin", directoryHint: .isDirectory).path
            var goInstallCommand = ["env", "GOBIN=\(gobinPath)", "go", "install"]

            goInstallCommand.append(installCommand)
            _ = try await model.executeInDirectory(in: packagePath.path, goInstallCommand)
        }
    }

    // MARK: - Build Binary

    func buildBinary(_ source: PackageSource, packagePath: URL) -> PackageManagerInstallStep {
        PackageManagerInstallStep(
            name: "Build From Source",
            confirmation: .none
        ) { model in
            // If there's a subpath, build the binary
            if let subpath = source.options["subpath"] {
                let binPath = packagePath.appending(path: "bin")
                if !FileManager.default.fileExists(atPath: binPath.path) {
                    try FileManager.default.createDirectory(at: binPath, withIntermediateDirectories: true)
                }

                let binaryName = subpath.components(separatedBy: "/").last ??
                source.pkgName.components(separatedBy: "/").last ?? source.pkgName
                let buildArgs = ["go", "build", "-o", "bin/\(binaryName)"]

                // If source.pkgName includes the full import path (like github.com/owner/repo)
                if source.pkgName.contains("/") {
                    _ = try await model.executeInDirectory(
                        in: packagePath.path, buildArgs + ["\(source.pkgName)/\(subpath)"]
                    )
                } else {
                    _ = try await model.executeInDirectory(
                        in: packagePath.path, buildArgs + [subpath]
                    )
                }
                let execPath = packagePath.appending(path: "bin").appending(path: binaryName)
                try FileManager.default.makeExecutable(execPath)
            }
        }
    }

    // MARK: - Helper methods

    /// Clean up after a failed installation
    private func cleanupFailedInstallation(packagePath: URL) throws {
        let goSumPath = packagePath.appending(path: "go.sum")
        if FileManager.default.fileExists(atPath: goSumPath.path) {
            try FileManager.default.removeItem(at: goSumPath)
        }
    }

    private func getGoInstallCommand(_ source: PackageSource) -> String {
        if let gitRef = source.gitReference, let repoUrl = source.repositoryUrl {
            // Check if this is a Git-based package
            var packageName = source.pkgName
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

            return "\(packageName)@\(gitVersion)"
        } else {
            return "\(source.pkgName)@\(source.version)"
        }
    }
}
