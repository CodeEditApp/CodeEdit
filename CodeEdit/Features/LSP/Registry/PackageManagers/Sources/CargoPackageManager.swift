//
//  CargoPackageManager.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/3/25.
//

import Foundation

final class CargoPackageManager: PackageManagerProtocol {
    private let installationDirectory: URL

    let shellClient: ShellClient

    init(installationDirectory: URL) {
        self.installationDirectory = installationDirectory
        self.shellClient = .live()
    }

    func install(method installationMethod: InstallationMethod) throws -> [PackageManagerInstallStep] {
        guard case .standardPackage(let source) = installationMethod else {
            throw PackageManagerError.invalidConfiguration
        }
        let packagePath = installationDirectory.appending(path: source.entryName)
        return [
            initialize(in: packagePath),
            runCargoInstall(source, in: packagePath)
        ]
    }

    func isInstalled(method installationMethod: InstallationMethod) -> PackageManagerInstallStep {
        PackageManagerInstallStep(
            name: "",
            confirmation: .none
        ) { model in
            let versionOutput = try await model.runCommand("cargo --version")
            let output = versionOutput.reduce(into: "") {
                $0 += $1.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            guard output.starts(with: "cargo") else {
                throw PackageManagerError.packageManagerNotInstalled
            }
        }
    }

    func getBinaryPath(for package: String) -> String {
        return installationDirectory.appending(path: package).appending(path: "bin").path
    }

    func initialize(in packagePath: URL) -> PackageManagerInstallStep {
        PackageManagerInstallStep(name: "Initialize Directory Structure", confirmation: .none) { model in
            try await model.createDirectoryStructure(for: packagePath)
        }
    }

    func runCargoInstall(_ source: PackageSource, in packagePath: URL) -> PackageManagerInstallStep {
        let qualifiedPackageName = "\(source.pkgName)@\(source.version)"

        return PackageManagerInstallStep(
            name: "Install Package Using cargo",
            confirmation: .required(
                message: "This requires the cargo package \(qualifiedPackageName)."
                + "\nAllow CodeEdit to install this package?"
            )
        ) { model in
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
                cargoArgs.append(qualifiedPackageName)
            }

            if let features = source.options["features"] {
                cargoArgs.append(contentsOf: ["--features", features])
            }
            if source.options["locked"] == "true" {
                cargoArgs.append("--locked")
            }

            try await model.executeInDirectory(in: packagePath.path(percentEncoded: false), cargoArgs)
        }
    }
}
